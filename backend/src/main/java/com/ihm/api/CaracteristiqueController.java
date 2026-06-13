package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.CaracteristiqueDTO;
import com.ihm.service.CaracteristiqueService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/caracteristiques")
public class CaracteristiqueController {

    private static final Logger log = LoggerFactory.getLogger(CaracteristiqueController.class);

    private final CaracteristiqueService caracteristiqueService;

    public CaracteristiqueController(CaracteristiqueService caracteristiqueService) {
        this.caracteristiqueService = caracteristiqueService;
    }

    @GetMapping("/by-categorie/{codeCategorie}")
    public ResponseEntity<ApiResponse<List<CaracteristiqueDTO>>> getByCategorie(@PathVariable String codeCategorie) {
        log.info("GET /api/caracteristiques/by-categorie/{}", codeCategorie);
        List<CaracteristiqueDTO> data = caracteristiqueService.getByCategorie(codeCategorie);
        return ResponseEntity.ok(ApiResponse.success(200, "Characteristics fetched successfully", data));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CaracteristiqueDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/caracteristiques/{}", id);
        CaracteristiqueDTO data = caracteristiqueService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Characteristic fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CaracteristiqueDTO>> create(@Valid @RequestBody CaracteristiqueDTO dto) {
        log.info("POST /api/caracteristiques - nom: {}", dto.getNom());
        CaracteristiqueDTO data = caracteristiqueService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Characteristic created successfully", data));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CaracteristiqueDTO>> update(@PathVariable Integer id,
                                                                   @Valid @RequestBody CaracteristiqueDTO dto) {
        log.info("PUT /api/caracteristiques/{}", id);
        CaracteristiqueDTO data = caracteristiqueService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Characteristic updated successfully", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/caracteristiques/{}", id);
        caracteristiqueService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Characteristic deleted successfully"));
    }
}
