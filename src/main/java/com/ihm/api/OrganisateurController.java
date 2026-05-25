package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.OrganisateurDTO;
import com.ihm.service.OrganisateurService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/organisateurs")
public class OrganisateurController {

    private static final Logger log = LoggerFactory.getLogger(OrganisateurController.class);

    private final OrganisateurService organisateurService;

    public OrganisateurController(OrganisateurService organisateurService) {
        this.organisateurService = organisateurService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<OrganisateurDTO>>> getAll() {
        log.info("GET /api/organisateurs");
        List<OrganisateurDTO> data = organisateurService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateurs fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<OrganisateurDTO>> getById(@PathVariable String code) {
        log.info("GET /api/organisateurs/{}", code);
        OrganisateurDTO data = organisateurService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<OrganisateurDTO>> create(@Valid @RequestBody OrganisateurDTO dto) {
        log.info("POST /api/organisateurs - email: {}", dto.getEmail());
        OrganisateurDTO data = organisateurService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Organisateur created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<OrganisateurDTO>> update(@PathVariable String code,
                                                                @Valid @RequestBody OrganisateurDTO dto) {
        log.info("PUT /api/organisateurs/{}", code);
        OrganisateurDTO data = organisateurService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/organisateurs/{}", code);
        organisateurService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur deleted successfully"));
    }
}
