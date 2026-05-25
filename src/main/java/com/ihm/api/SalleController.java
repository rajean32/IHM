package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.SalleDTO;
import com.ihm.service.SalleService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/salles")
public class SalleController {

    private static final Logger log = LoggerFactory.getLogger(SalleController.class);

    private final SalleService salleService;

    public SalleController(SalleService salleService) {
        this.salleService = salleService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getAll() {
        log.info("GET /api/salles");
        List<SalleDTO> data = salleService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Rooms fetched successfully", data));
    }

    @GetMapping("/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> getById(@PathVariable String numero) {
        log.info("GET /api/salles/{}", numero);
        SalleDTO data = salleService.getById(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Room fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<SalleDTO>> create(@Valid @RequestBody SalleDTO dto) {
        log.info("POST /api/salles - numero: {}", dto.getNumeroSalle());
        SalleDTO data = salleService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Room created successfully", data));
    }

    @PutMapping("/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> update(@PathVariable String numero, @Valid @RequestBody SalleDTO dto) {
        log.info("PUT /api/salles/{}", numero);
        SalleDTO data = salleService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Room updated successfully", data));
    }

    @DeleteMapping("/{numero}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String numero) {
        log.info("DELETE /api/salles/{}", numero);
        salleService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Room deleted successfully"));
    }
}
