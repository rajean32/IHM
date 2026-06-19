package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.AuthDTO;
import com.ihm.schema.PasswordDTO;
import com.ihm.service.AuthService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // connexion utilisateur
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthDTO.LoginResponse>> login(@Valid @RequestBody AuthDTO.LoginRequest request) {
        log.info("POST /api/auth/login - email: {}", request.getEmail());
        AuthDTO.LoginResponse data = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(200, "Login successful", data));
    }
    // crearion de compte
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthDTO.LoginResponse>> register(@Valid @RequestBody AuthDTO.RegisterRequest request) {
        log.info("POST /api/auth/register - email: {}", request.getEmail());
        AuthDTO.LoginResponse data = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Registration successful", data));
    }

    @PostMapping("/first-login-update")
    public ResponseEntity<ApiResponse<AuthDTO.LoginResponse>> firstLoginUpdate(@Valid @RequestBody AuthDTO.FirstLoginUpdateRequest request) {
        log.info("POST /api/auth/first-login-update - user: {}", request.getCodeUtilisateur());
        AuthDTO.LoginResponse data = authService.firstLoginUpdate(request);
        return ResponseEntity.ok(ApiResponse.success(200, "First login update successful", data));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> forgotPassword(@Valid @RequestBody PasswordDTO.ResetRequest request) {
        log.info("POST /api/auth/forgot-password - email: {}", request.getEmail());
        String token = authService.requestPasswordReset(request.getEmail());
        Map<String, String> data = Map.of(
                "message", "Reset token generated. In production, this would be sent via email.",
                "token", token
        );
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset token generated", data));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> resetPassword(@Valid @RequestBody PasswordDTO.ResetConfirmRequest request) {
        log.info("POST /api/auth/reset-password - email: {}", request.getEmail());
        authService.confirmPasswordReset(request.getEmail(), request.getToken(), request.getNewPassword());
        Map<String, String> data = Map.of("message", "Password reset successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset successful", data));
    }

    @PutMapping("/ville")
    public ResponseEntity<ApiResponse<Map<String, String>>> updateVille(@Valid @RequestBody AuthDTO.UpdateVilleRequest request) {
        log.info("PUT /api/auth/ville - user: {}, ville: {}", request.getCodeUtilisateur(), request.getVille());
        authService.updateVille(request.getCodeUtilisateur(), request.getVille(), request.getVilleCode());
        Map<String, String> data = Map.of("message", "Ville updated successfully", "ville", request.getVille(), "villeCode", request.getVilleCode());
        return ResponseEntity.ok(ApiResponse.success(200, "Ville updated successfully", data));
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiResponse<Map<String, String>>> changePassword(@Valid @RequestBody PasswordDTO.ChangeRequest request) {
        String codeUtilisateur = SecurityContextHolder.getContext().getAuthentication() != null
                ? (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal()
                : null;

        if (codeUtilisateur == null) {
            return ResponseEntity.status(401).body(ApiResponse.error(401, "Authentication required", "No authenticated user"));
        }

        log.info("PUT /api/auth/change-password - user: {}", codeUtilisateur);
        authService.changePassword(codeUtilisateur, request.getCurrentPassword(), request.getNewPassword());
        Map<String, String> data = Map.of("message", "Password changed successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Password changed successfully", data));
    }
}
