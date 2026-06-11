package com.ihm.api;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.CategorieDTO;
import com.ihm.service.CategorieService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/categories")
public class CategorieController {

    private static final Logger log = LoggerFactory.getLogger(CategorieController.class);

    private final CategorieService categorieService;
    private final ObjectMapper objectMapper;

    public CategorieController(CategorieService categorieService, ObjectMapper objectMapper) {
        this.categorieService = categorieService;
        this.objectMapper = objectMapper;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CategorieDTO>>> getAll() {
        log.info("GET /api/categories");
        List<CategorieDTO> data = categorieService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Categories fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<CategorieDTO>> getById(@PathVariable String code) {
        log.info("GET /api/categories/{}", code);
        CategorieDTO data = categorieService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Category fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CategorieDTO>> create(@Valid @RequestBody CategorieDTO dto) {
        log.info("POST /api/categories - DTO: {}", dto);
        CategorieDTO data = categorieService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Category created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<CategorieDTO>> update(@PathVariable String code,
                                                             @Valid @RequestBody CategorieDTO dto) {
        log.info("PUT /api/categories/{}", code);
        CategorieDTO data = categorieService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Category updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/categories/{}", code);
        categorieService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Category deleted successfully"));
    }

    @PostMapping("/{code}/salle-types/{numeroSalle}")
    public ResponseEntity<ApiResponse<Void>> addSalleType(@PathVariable String code,
                                                           @PathVariable String numeroSalle) {
        log.info("POST /api/categories/{}/salle-types/{}", code, numeroSalle);
        categorieService.addSalleType(code, numeroSalle);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle type added to category successfully"));
    }

    @DeleteMapping("/{code}/salle-types/{numeroSalle}")
    public ResponseEntity<ApiResponse<Void>> removeSalleType(@PathVariable String code,
                                                              @PathVariable String numeroSalle) {
        log.info("DELETE /api/categories/{}/salle-types/{}", code, numeroSalle);
        categorieService.removeSalleType(code, numeroSalle);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle type removed from category successfully"));
    }

    @GetMapping("/{code}/config")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getConfig(@PathVariable String code) {
        log.info("GET /api/categories/{}/config", code);
        String json = categorieService.getSpecificConfig(code);
        if (json == null || json.isEmpty()) {
            return ResponseEntity.ok(ApiResponse.success(200, "No config found", null));
        }
        try {
            Map<String, Object> config = objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
            return ResponseEntity.ok(ApiResponse.success(200, "Config fetched successfully", config));
        } catch (JsonProcessingException e) {
            log.error("Failed to parse config for category {}", code, e);
            return ResponseEntity.ok(ApiResponse.success(200, "No config found", null));
        }
    }

    @PutMapping("/{code}/config")
    public ResponseEntity<ApiResponse<Void>> updateConfig(@PathVariable String code,
                                                           @RequestBody Map<String, Object> config) {
        log.info("PUT /api/categories/{}/config", code);
        categorieService.updateSpecificConfig(code, config);
        return ResponseEntity.ok(ApiResponse.success(200, "Config updated successfully"));
    }
}
