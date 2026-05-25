package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.LieuDTO;
import com.ihm.service.LieuService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lieux")
public class LieuController {

    private static final Logger log = LoggerFactory.getLogger(LieuController.class);

    private final LieuService lieuService;

    public LieuController(LieuService lieuService) {
        this.lieuService = lieuService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<LieuDTO>>> getAll() {
        log.info("GET /api/lieux");
        List<LieuDTO> data = lieuService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Locations fetched successfully", data));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<LieuDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/lieux/{}", id);
        LieuDTO data = lieuService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Location fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<LieuDTO>> create(@Valid @RequestBody LieuDTO dto) {
        log.info("POST /api/lieux - name: {}", dto.getNomLieu());
        LieuDTO data = lieuService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Location created successfully", data));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<LieuDTO>> update(@PathVariable Integer id, @Valid @RequestBody LieuDTO dto) {
        log.info("PUT /api/lieux/{}", id);
        LieuDTO data = lieuService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Location updated successfully", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/lieux/{}", id);
        lieuService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Location deleted successfully"));
    }
}
