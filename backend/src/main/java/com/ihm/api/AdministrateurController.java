package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.AdministrateurDTO;
import com.ihm.service.AdministrateurService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/administrateurs")
public class AdministrateurController {

    private static final Logger log = LoggerFactory.getLogger(AdministrateurController.class);

    private final AdministrateurService administrateurService;

    public AdministrateurController(AdministrateurService administrateurService) {
        this.administrateurService = administrateurService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<AdministrateurDTO>>> getAll() {
        log.info("GET /api/administrateurs");
        List<AdministrateurDTO> data = administrateurService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Administrators fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<AdministrateurDTO>> getById(@PathVariable String code) {
        log.info("GET /api/administrateurs/{}", code);
        AdministrateurDTO data = administrateurService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AdministrateurDTO>> create(@Valid @RequestBody AdministrateurDTO dto) {
        log.info("POST /api/administrateurs - code: {}", dto.getCodeAdministrateur());
        AdministrateurDTO data = administrateurService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Administrator created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<AdministrateurDTO>> update(@PathVariable String code,
                                                                  @Valid @RequestBody AdministrateurDTO dto) {
        log.info("PUT /api/administrateurs/{}", code);
        AdministrateurDTO data = administrateurService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/administrateurs/{}", code);
        administrateurService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Administrator deleted successfully"));
    }
}
