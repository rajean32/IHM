package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.*;
import com.ihm.service.ActionLogService;
import com.ihm.service.AdminUserService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    private static final Logger log = LoggerFactory.getLogger(AdminUserController.class);

    private final AdminUserService adminUserService;
    private final ActionLogService actionLogService;

    public AdminUserController(AdminUserService adminUserService, ActionLogService actionLogService) {
        this.adminUserService = adminUserService;
        this.actionLogService = actionLogService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<UserDetailDTO>>> getAllUsers() {
        log.info("GET /api/admin/users");
        List<UserDetailDTO> users = adminUserService.getAllUsers();
        return ResponseEntity.ok(ApiResponse.success(200, "Users fetched successfully", users));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<UserDetailDTO>> getUserById(@PathVariable String code) {
        log.info("GET /api/admin/users/{}", code);
        UserDetailDTO user = adminUserService.getUserById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User fetched successfully", user));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<UserDetailDTO>> createUser(
            @Valid @RequestBody UserCreateRequest request,
            Authentication auth) {
        log.info("POST /api/admin/users - email: {}", request.getEmail());
        String adminCode = auth.getName();
        UserDetailDTO user = adminUserService.createUser(request, adminCode);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "User created successfully", user));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<UserDetailDTO>> updateUser(
            @PathVariable String code,
            @Valid @RequestBody UserCreateRequest request,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}", code);
        String adminCode = auth.getName();
        UserDetailDTO user = adminUserService.updateUser(code, request, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User updated successfully", user));
    }

    @PutMapping("/{code}/role")
    public ResponseEntity<ApiResponse<UserDetailDTO>> updateUserRole(
            @PathVariable String code,
            @Valid @RequestBody UserRoleUpdateRequest request,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}/role", code);
        String adminCode = auth.getName();
        UserDetailDTO user = adminUserService.updateUserRole(code, request, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User role updated successfully", user));
    }

    @PutMapping("/{code}/toggle-active")
    public ResponseEntity<ApiResponse<Void>> toggleUserActive(
            @PathVariable String code,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}/toggle-active", code);
        String adminCode = auth.getName();
        adminUserService.toggleUserActive(code, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User status toggled successfully"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody PasswordResetAdminRequest request,
            Authentication auth) {
        log.info("POST /api/admin/users/reset-password");
        String adminCode = auth.getName();
        adminUserService.resetPassword(request.getCodeUtilisateur(), request.getNewPassword(), adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset successfully"));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(
            @PathVariable String code,
            Authentication auth) {
        log.info("DELETE /api/admin/users/{}", code);
        String adminCode = auth.getName();
        adminUserService.deleteUser(code, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User deleted successfully"));
    }

    @GetMapping("/audit-log")
    public ResponseEntity<ApiResponse<List<com.ihm.schemat.ActionLog>>> getAuditLog() {
        log.info("GET /api/admin/users/audit-log");
        List<com.ihm.schemat.ActionLog> logs = actionLogService.getRecentActions();
        return ResponseEntity.ok(ApiResponse.success(200, "Audit log fetched successfully", logs));
    }
}
