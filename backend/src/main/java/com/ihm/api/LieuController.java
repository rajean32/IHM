package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.LieuDTO;
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

    // liste des lieux
    @GetMapping
    public ResponseEntity<ApiResponse<List<LieuDTO>>> getAll() {
        log.info("GET /api/lieux");
        List<LieuDTO> data = lieuService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Locations fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<LieuDTO>> getByCode(@PathVariable String code) {
        log.info("GET /api/lieux/{}", code);
        LieuDTO data = lieuService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Location fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<LieuDTO>> create(@Valid @RequestBody LieuDTO dto) {
        log.info("POST /api/lieux - name: {}", dto.getNomLieu());
        LieuDTO data = lieuService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Location created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<LieuDTO>> update(@PathVariable String code, @Valid @RequestBody LieuDTO dto) {
        log.info("PUT /api/lieux/{}", code);
        LieuDTO data = lieuService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Location updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/lieux/{}", code);
        lieuService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Location deleted successfully"));
    }
}
