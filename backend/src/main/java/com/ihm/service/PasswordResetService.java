package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schemat.Utilisateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PasswordResetService {

    private static final Logger log = LoggerFactory.getLogger(PasswordResetService.class);
    private static final Map<String, ResetToken> TOKEN_STORE = new ConcurrentHashMap<>();

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    public PasswordResetService(UtilisateurRepository utilisateurRepository,
                                PasswordEncoder passwordEncoder) {
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public String requestPasswordReset(String email) {
        log.debug("Password reset requested for email: {}", email);
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "email", email));

        String token = UUID.randomUUID().toString();
        TOKEN_STORE.put(token, new ResetToken(user.getCodeUtilisateur(), System.currentTimeMillis()));

        log.info("Password reset token generated for user: {}", user.getCodeUtilisateur());
        return token;
    }

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

    private static class ResetToken {
        private final String codeUtilisateur;
        private final long createdAt;

        ResetToken(String codeUtilisateur, long createdAt) {
            this.codeUtilisateur = codeUtilisateur;
            this.createdAt = createdAt;
        }
    }
}
