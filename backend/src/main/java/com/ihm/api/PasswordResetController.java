package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.PasswordChangeRequest;
import com.ihm.model.dto.PasswordResetConfirmRequest;
import com.ihm.model.dto.PasswordResetRequest;
import com.ihm.service.PasswordResetService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class PasswordResetController {

    private static final Logger log = LoggerFactory.getLogger(PasswordResetController.class);

    private final PasswordResetService passwordResetService;

    public PasswordResetController(PasswordResetService passwordResetService) {
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> forgotPassword(@Valid @RequestBody PasswordResetRequest request) {
        log.info("POST /api/auth/forgot-password - email: {}", request.getEmail());
        String token = passwordResetService.requestPasswordReset(request.getEmail());
        Map<String, String> data = Map.of(
                "message", "Reset token generated. In production, this would be sent via email.",
                "token", token
        );
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset token generated", data));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> resetPassword(@Valid @RequestBody PasswordResetConfirmRequest request) {
        log.info("POST /api/auth/reset-password - email: {}", request.getEmail());
        passwordResetService.confirmPasswordReset(request.getEmail(), request.getToken(), request.getNewPassword());
        Map<String, String> data = Map.of("message", "Password reset successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset successful", data));
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> changePassword(@Valid @RequestBody PasswordChangeRequest request) {
        String codeUtilisateur = SecurityContextHolder.getContext().getAuthentication() != null
                ? (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal()
                : null;

        if (codeUtilisateur == null) {
            return ResponseEntity.status(401).body(ApiResponse.error(401, "Authentication required", "No authenticated user"));
        }

        log.info("PUT /api/auth/change-password - user: {}", codeUtilisateur);
        passwordResetService.changePassword(codeUtilisateur, request.getCurrentPassword(), request.getNewPassword());
        Map<String, String> data = Map.of("message", "Password changed successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Password changed successfully", data));
    }
}
