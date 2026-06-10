package com.ihm.security;

import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Utilisateur;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class FirstLoginCheckFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(FirstLoginCheckFilter.class);

    private static final List<String> ALLOWED_PATHS = List.of(
        "/api/auth/first-login-update",
        "/api/auth/logout",
        "/api/auth/login",
        "/api/auth/register",
        "/swagger-ui.html",
        "/swagger-ui/",
        "/api-docs/",
        "/v3/api-docs/"
    );

    private final UtilisateurRepository utilisateurRepository;

    public FirstLoginCheckFilter(UtilisateurRepository utilisateurRepository) {
        this.utilisateurRepository = utilisateurRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof String codeUtilisateur) {
            String path = request.getRequestURI();

            if (isAllowedPath(path)) {
                filterChain.doFilter(request, response);
                return;
            }

            Utilisateur user = utilisateurRepository.findByCodeUtilisateur(codeUtilisateur).orElse(null);
            if (user != null && user.isPremiereConnexion()) {
                boolean isAdmin = auth.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_ADMINISTRATEUR".equals(a.getAuthority()));
                if (isAdmin) {
                    log.warn("Blocked request from admin {} with premiereConnexion=true: {} {}",
                        codeUtilisateur, request.getMethod(), path);
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json");
                    response.getWriter().write(
                        "{\"status\":403,\"message\":\"First login setup required. Please update your email and password before accessing other features.\"}"
                    );
                    return;
                }
            }
        }

        filterChain.doFilter(request, response);
    }

    private boolean isAllowedPath(String path) {
        for (String allowed : ALLOWED_PATHS) {
            if (path.equals(allowed) || path.startsWith(allowed)) {
                return true;
            }
        }
        return false;
    }
}
