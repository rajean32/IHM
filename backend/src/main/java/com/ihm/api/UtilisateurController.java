package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.PasswordDTO;
import com.ihm.schema.UtilisateurDTO;
import com.ihm.model.ActionLog;
import com.ihm.service.ActionLogService;
import com.ihm.service.UtilisateurService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class UtilisateurController {

    private static final Logger log = LoggerFactory.getLogger(UtilisateurController.class);

    private final UtilisateurService utilisateurService;
    private final ActionLogService actionLogService;

    public UtilisateurController(UtilisateurService utilisateurService,
                                 ActionLogService actionLogService) {
        this.utilisateurService = utilisateurService;
        this.actionLogService = actionLogService;
    }

    // liste des utilisateurs
    @GetMapping("/utilisateurs")
    public ResponseEntity<ApiResponse<List<UtilisateurDTO>>> getAll() {
        log.info("GET /api/utilisateurs");
        List<UtilisateurDTO> data = utilisateurService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Users fetched successfully", data));
    }

    // utilisateur par code
    @GetMapping("/utilisateurs/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO>> getById(@PathVariable String code) {
        log.info("GET /api/utilisateurs/{}", code);
        UtilisateurDTO data = utilisateurService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User fetched successfully", data));
    }

    // creation d'utilisateur
    @PostMapping("/utilisateurs")
    public ResponseEntity<ApiResponse<UtilisateurDTO>> create(@Valid @RequestBody UtilisateurDTO dto) {
        log.info("POST /api/utilisateurs - email: {}", dto.getEmail());
        UtilisateurDTO data = utilisateurService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "User created successfully", data));
    }

    // modification d'utilisateur
    @PutMapping("/utilisateurs/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO>> update(@PathVariable String code,
                                                               @Valid @RequestBody UtilisateurDTO dto) {
        log.info("PUT /api/utilisateurs/{}", code);
        UtilisateurDTO data = utilisateurService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "User updated successfully", data));
    }

    // suppression d'utilisateur
    @DeleteMapping("/utilisateurs/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/utilisateurs/{}", code);
        utilisateurService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User deleted successfully"));
    }

    // liste des administrateurs
    @GetMapping("/administrateurs")
    public ResponseEntity<ApiResponse<List<UtilisateurDTO.AdministrateurDTO>>> getAllAdmins() {
        log.info("GET /api/administrateurs");
        List<UtilisateurDTO.AdministrateurDTO> data = utilisateurService.getAllAdministrateurs();
        return ResponseEntity.ok(ApiResponse.success(200, "Administrators fetched successfully", data));
    }

    // administrateur par code
    @GetMapping("/administrateurs/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO.AdministrateurDTO>> getAdminById(@PathVariable String code) {
        log.info("GET /api/administrateurs/{}", code);
        UtilisateurDTO.AdministrateurDTO data = utilisateurService.getAdministrateurById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator fetched successfully", data));
    }

    // creation d'administrateur
    @PostMapping("/administrateurs")
    public ResponseEntity<ApiResponse<UtilisateurDTO.AdministrateurDTO>> createAdmin(@Valid @RequestBody UtilisateurDTO.AdministrateurDTO dto) {
        log.info("POST /api/administrateurs - code: {}", dto.getCodeAdministrateur());
        UtilisateurDTO.AdministrateurDTO data = utilisateurService.createAdministrateur(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Administrator created successfully", data));
    }

    // modification d'administrateur
    @PutMapping("/administrateurs/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO.AdministrateurDTO>> updateAdmin(@PathVariable String code,
                                                                      @Valid @RequestBody UtilisateurDTO.AdministrateurDTO dto) {
        log.info("PUT /api/administrateurs/{}", code);
        UtilisateurDTO.AdministrateurDTO data = utilisateurService.updateAdministrateur(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator updated successfully", data));
    }

    // suppression d'administrateur
    @DeleteMapping("/administrateurs/{code}")
    public ResponseEntity<ApiResponse<Void>> deleteAdmin(@PathVariable String code) {
        log.info("DELETE /api/administrateurs/{}", code);
        utilisateurService.deleteAdministrateur(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator deleted successfully"));
    }

    // liste des utilisateurs (admin)
    @GetMapping("/admin/users")
    public ResponseEntity<ApiResponse<List<UtilisateurDTO.UserDetail>>> getAllUsers() {
        log.info("GET /api/admin/users");
        List<UtilisateurDTO.UserDetail> users = utilisateurService.getAllUsers();
        return ResponseEntity.ok(ApiResponse.success(200, "Users fetched successfully", users));
    }

    // utilisateur par code (admin)
    @GetMapping("/admin/users/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO.UserDetail>> getUserById(@PathVariable String code) {
        log.info("GET /api/admin/users/{}", code);
        UtilisateurDTO.UserDetail user = utilisateurService.getUserById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User fetched successfully", user));
    }
    
    // creation utilisateur
    @PostMapping("/admin/users")
    public ResponseEntity<ApiResponse<UtilisateurDTO.UserDetail>> createUser(
            @Valid @RequestBody UtilisateurDTO.UserCreateRequest request,
            Authentication auth) {
        log.info("POST /api/admin/users - email: {}", request.getEmail());
        String adminCode = auth.getName();
        UtilisateurDTO.UserDetail user = utilisateurService.createUser(request, adminCode);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "User created successfully", user));
    }

    // modification d'utilisateur (admin)
    @PutMapping("/admin/users/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO.UserDetail>> updateUser(
            @PathVariable String code,
            @Valid @RequestBody UtilisateurDTO.UserUpdateRequest request,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}", code);
        String adminCode = auth.getName();
        UtilisateurDTO.UserDetail user = utilisateurService.updateUser(code, request, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User updated successfully", user));
    }

    // changement de role (admin)
    @PutMapping("/admin/users/{code}/role")
    public ResponseEntity<ApiResponse<UtilisateurDTO.UserDetail>> updateUserRole(
            @PathVariable String code,
            @Valid @RequestBody UtilisateurDTO.UserRoleUpdateRequest request,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}/role", code);
        String adminCode = auth.getName();
        UtilisateurDTO.UserDetail user = utilisateurService.updateUserRole(code, request, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User role updated successfully", user));
    }

    // activer/desactiver utilisateur (admin)
    @PutMapping("/admin/users/{code}/toggle-active")
    public ResponseEntity<ApiResponse<Void>> toggleUserActive(
            @PathVariable String code,
            Authentication auth) {
        log.info("PUT /api/admin/users/{}/toggle-active", code);
        String adminCode = auth.getName();
        utilisateurService.toggleUserActive(code, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User status toggled successfully"));
    }

    // reinitialisation mot de passe (admin)
    @PostMapping("/admin/users/reset-password")
    public ResponseEntity<ApiResponse<Void>> adminResetPassword(
            @Valid @RequestBody PasswordDTO.AdminResetRequest request,
            Authentication auth) {
        log.info("POST /api/admin/users/reset-password");
        String adminCode = auth.getName();
        utilisateurService.resetPassword(request.getCodeUtilisateur(), request.getNewPassword(), adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "Password reset successfully"));
    }

    // suppression d'utilisateur (admin)
    @DeleteMapping("/admin/users/{code}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(
            @PathVariable String code,
            Authentication auth) {
        log.info("DELETE /api/admin/users/{}", code);
        String adminCode = auth.getName();
        utilisateurService.deleteUser(code, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, "User deleted successfully"));
    }

    // journal d'audit (admin)
    @GetMapping("/admin/users/audit-log")
    public ResponseEntity<ApiResponse<List<ActionLog>>> getAuditLog() {
        log.info("GET /api/admin/users/audit-log");
        List<ActionLog> logs = actionLogService.getRecentActions();
        return ResponseEntity.ok(ApiResponse.success(200, "Audit log fetched successfully", logs));
    }

    // annulation d'une action (undo)
    @PostMapping("/admin/audit-log/{id}/undo")
    public ResponseEntity<ApiResponse<String>> undoAction(@PathVariable Long id, Authentication auth) {
        log.info("POST /api/admin/audit-log/{}/undo", id);
        String adminCode = auth.getName();
        String result = actionLogService.undoAction(id, adminCode);
        return ResponseEntity.ok(ApiResponse.success(200, result, result));
    }

    // verification coherence (admin)
    @GetMapping("/admin/consistency")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<UtilisateurDTO.ConsistencyReport>> checkConsistency() {
        log.info("GET /api/admin/consistency");
        UtilisateurDTO.ConsistencyReport report = utilisateurService.generateReport();
        return ResponseEntity.ok(ApiResponse.success(200, "Consistency check completed", report));
    }
}
