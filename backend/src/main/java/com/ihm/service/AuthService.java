package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.AuthDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Administrateur;
import com.ihm.model.Client;
import com.ihm.model.Organisateur;
import com.ihm.model.Utilisateur;
import com.ihm.model.Ville;
import com.ihm.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private static final Map<String, ResetToken> TOKEN_STORE = new ConcurrentHashMap<>();

    private final UtilisateurRepository utilisateurRepository;
    private final OrganisateurRepository organisateurRepository;
    private final ClientRepository clientRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final VilleService villeService;

    public AuthService(UtilisateurRepository utilisateurRepository,
                       OrganisateurRepository organisateurRepository,
                       ClientRepository clientRepository,
                       AdministrateurRepository administrateurRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil,
                       VilleService villeService) {
        this.utilisateurRepository = utilisateurRepository;
        this.organisateurRepository = organisateurRepository;
        this.clientRepository = clientRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.villeService = villeService;
    }

    // connexion utilisateur
    public AuthDTO.LoginResponse login(AuthDTO.LoginRequest request) {
        log.debug("Login attempt for email: {}", request.getEmail());

        Utilisateur user = utilisateurRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "email", request.getEmail()));

        if (!passwordEncoder.matches(request.getMotDePasse(), user.getMotDePasse())) {
            throw new BadRequestException("Invalid email or password");
        }

        String role = determineRole(user);
        String token = jwtUtil.generateToken(user.getCodeUtilisateur(), role);

        log.info("User logged in: {} (firstLogin: {})", user.getCodeUtilisateur(), user.isPremiereConnexion());
        return new AuthDTO.LoginResponse(token, user.getCodeUtilisateur(), user.getEmail(), user.getNom(), user.getPrenoms(), role, user.isPremiereConnexion(), user.getVilleNom(), user.getVilleCode());
    }

    // inscription utilisateur
    @Transactional
    public AuthDTO.LoginResponse register(AuthDTO.RegisterRequest request) {
        log.debug("Register attempt for email: {}", request.getEmail());

        if (utilisateurRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Utilisateur", "email", request.getEmail());
        }

        String code = request.getCodeUtilisateur();
        if (code == null || code.isBlank()) {
            code = generateUserCode(request.getType());
        } else if (utilisateurRepository.existsByCodeUtilisateur(code)) {
            throw new DuplicateResourceException("Utilisateur", "codeUtilisateur", code);
        }
        request.setCodeUtilisateur(code);

        String type = (request.getType() != null) ? request.getType().toLowerCase() : "client";
        Utilisateur user;

        switch (type) {
            case "organisateur":
                Organisateur org = new Organisateur();
                populateFields(org, request);
                user = organisateurRepository.save(org);
                break;
            case "client":
            default:
                Client client = new Client();
                populateFields(client, request);
                user = clientRepository.save(client);
                break;
        }

        String role = type.equals("organisateur") ? "ORGANISATEUR" : "CLIENT";
        String token = jwtUtil.generateToken(user.getCodeUtilisateur(), role);

        log.info("User registered: {} as {}", user.getCodeUtilisateur(), role);
        return new AuthDTO.LoginResponse(token, user.getCodeUtilisateur(), user.getEmail(), user.getNom(), user.getPrenoms(), role, user.isPremiereConnexion(), user.getVilleNom(), user.getVilleCode());
    }

    // allocation
    private void populateFields(Utilisateur user, AuthDTO.RegisterRequest request) {
        user.setCodeUtilisateur(request.getCodeUtilisateur());
        user.setNom(request.getNom());
        user.setPrenoms(request.getPrenoms());
        user.setSexe(request.getSexe());
        user.setDateDeNaissance(request.getDateDeNaissance());
        user.setEmail(request.getEmail());
        user.setTel(request.getTel());
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
        user.setPremiereConnexion(true);
        if (request.getVille() != null && !request.getVille().isBlank()) {
            Ville ville = villeService.resolveOrCreateVille(request.getVilleCode(), request.getVille());
            user.setVille(ville);
        }
    }

    // mise a jour premiere connexion
    @Transactional
    public AuthDTO.LoginResponse firstLoginUpdate(AuthDTO.FirstLoginUpdateRequest request) {
        log.debug("First login update for user: {}", request.getCodeUtilisateur());

        String authenticatedUser = SecurityContextHolder.getContext().getAuthentication().getName();
        if (!authenticatedUser.equals(request.getCodeUtilisateur())) {
            throw new BadRequestException("Authenticated user does not match the user code in the request");
        }

        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(request.getCodeUtilisateur())
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "code", request.getCodeUtilisateur()));

        if (!user.isPremiereConnexion()) {
            throw new BadRequestException("First login already completed");
        }

        if (request.getNewEmail() != null && !request.getNewEmail().equals(user.getEmail())) {
            if (utilisateurRepository.existsByEmail(request.getNewEmail())) {
                throw new DuplicateResourceException("Utilisateur", "email", request.getNewEmail());
            }
            user.setEmail(request.getNewEmail());
        }

        if (request.getNewPassword() != null && !request.getNewPassword().isBlank()) {
            user.setMotDePasse(passwordEncoder.encode(request.getNewPassword()));
        }

        if (request.getVille() != null && !request.getVille().isBlank()) {
            Ville ville = villeService.resolveOrCreateVille(request.getVilleCode(), request.getVille());
            user.setVille(ville);
        }

        user.setPremiereConnexion(false);
        utilisateurRepository.save(user);

        String role = determineRole(user);
        String token = jwtUtil.generateToken(user.getCodeUtilisateur(), role);

        log.info("First login update completed for: {}", user.getCodeUtilisateur());
        return new AuthDTO.LoginResponse(token, user.getCodeUtilisateur(), user.getEmail(), user.getNom(), user.getPrenoms(), role, false, user.getVilleNom(), user.getVilleCode());
    }

    @Transactional
    public void updateVille(String codeUtilisateur, String ville, String villeCode) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(codeUtilisateur)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "code", codeUtilisateur));
        Ville v = villeService.resolveOrCreateVille(villeCode, ville);
        user.setVille(v);
        utilisateurRepository.save(user);
        log.info("Ville updated for user {}: {} ({})", codeUtilisateur, ville, villeCode);
    }

    // demande de reinitialisation mot de passe
    public String requestPasswordReset(String email) {
        log.debug("Password reset requested for email: {}", email);
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "email", email));

        String token = UUID.randomUUID().toString();
        TOKEN_STORE.put(token, new ResetToken(user.getCodeUtilisateur(), System.currentTimeMillis()));

        log.info("Password reset token generated for user: {}", user.getCodeUtilisateur());
        return token;
    }

    // confirmation reinitialisation mot de passe
    public boolean confirmPasswordReset(String email, String token, String newPassword) {
        log.debug("Password reset confirmation for email: {}", email);
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "email", email));

        ResetToken resetToken = TOKEN_STORE.get(token);
        if (resetToken == null) {
            throw new BadRequestException("Invalid reset token");
        }
        if (!resetToken.codeUtilisateur.equals(user.getCodeUtilisateur())) {
            throw new BadRequestException("Reset token does not match user");
        }
        long elapsed = System.currentTimeMillis() - resetToken.createdAt;
        if (elapsed > 3600000) {
            TOKEN_STORE.remove(token);
            throw new BadRequestException("Reset token has expired");
        }

        user.setMotDePasse(passwordEncoder.encode(newPassword));
        utilisateurRepository.save(user);
        TOKEN_STORE.remove(token);

        log.info("Password reset successful for user: {}", user.getCodeUtilisateur());
        return true;
    }

    // changement de mot de passe
    public boolean changePassword(String codeUtilisateur, String currentPassword, String newPassword) {
        log.debug("Password change requested for user: {}", codeUtilisateur);
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(codeUtilisateur)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", codeUtilisateur));

        if (!passwordEncoder.matches(currentPassword, user.getMotDePasse())) {
            throw new BadRequestException("Current password is incorrect");
        }

        user.setMotDePasse(passwordEncoder.encode(newPassword));
        utilisateurRepository.save(user);

        log.info("Password changed for user: {}", codeUtilisateur);
        return true;
    }

    private String generateUserCode(String type) {
        String prefix = "client".equalsIgnoreCase(type) ? "CLT" : "ORG";
        return prefix + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    // recherche role avec le code user
    private String determineRole(Utilisateur user) {
        if (administrateurRepository.findByCodeAdministrateur(user.getCodeUtilisateur()).isPresent()) {
            return "ADMINISTRATEUR";
        }
        if (organisateurRepository.findByCodeUtilisateur(user.getCodeUtilisateur()).isPresent()) {
            return "ORGANISATEUR";
        }
        if (clientRepository.findByCodeUtilisateur(user.getCodeUtilisateur()).isPresent()) {
            return "CLIENT";
        }
        return "UTILISATEUR";
    }
    // reinitialisation token

    private static class ResetToken {
        private final String codeUtilisateur;
        private final long createdAt;

        ResetToken(String codeUtilisateur, long createdAt) {
            this.codeUtilisateur = codeUtilisateur;
            this.createdAt = createdAt;
        }
    }
}
