package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.UtilisateurDTO;
import com.ihm.service.UtilisateurService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/utilisateurs")
public class UtilisateurController {

    private static final Logger log = LoggerFactory.getLogger(UtilisateurController.class);

    private final UtilisateurService utilisateurService;

    public UtilisateurController(UtilisateurService utilisateurService) {
        this.utilisateurService = utilisateurService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<UtilisateurDTO>>> getAll() {
        log.info("GET /api/utilisateurs");
        List<UtilisateurDTO> data = utilisateurService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Users fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO>> getById(@PathVariable String code) {
        log.info("GET /api/utilisateurs/{}", code);
        UtilisateurDTO data = utilisateurService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<UtilisateurDTO>> create(@Valid @RequestBody UtilisateurDTO dto) {
        log.info("POST /api/utilisateurs - email: {}", dto.getEmail());
        UtilisateurDTO data = utilisateurService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "User created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<UtilisateurDTO>> update(@PathVariable String code,
                                                               @Valid @RequestBody UtilisateurDTO dto) {
        log.info("PUT /api/utilisateurs/{}", code);
        UtilisateurDTO data = utilisateurService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "User updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/utilisateurs/{}", code);
        utilisateurService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "User deleted successfully"));
    }
}
