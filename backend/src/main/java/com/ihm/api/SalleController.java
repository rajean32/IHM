package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.SalleDTO;
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

    // toutes les salles
    @GetMapping
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getAll() {
        log.info("GET /api/salles");
        List<SalleDTO> data = salleService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Rooms fetched successfully", data));
    }

    // salle par numero
    @GetMapping("/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> getById(@PathVariable String numero) {
        log.info("GET /api/salles/{}", numero);
        SalleDTO data = salleService.getById(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Room fetched successfully", data));
    }

    // creation de salle
    @PostMapping
    public ResponseEntity<ApiResponse<SalleDTO>> create(@Valid @RequestBody SalleDTO dto) {
        log.info("POST /api/salles - numero: {}", dto.getNumeroSalle());

        SalleDTO data = salleService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Room created successfully", data));
    }

    // modification de salle
    @PutMapping("/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> update(@PathVariable String numero, @Valid @RequestBody SalleDTO dto) {
        log.debug("Recherche utilisateur");        SalleDTO data = salleService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Room updated successfully", data));
    }

    // suppression de salle
    @DeleteMapping("/{numero}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String numero) {
        log.info("DELETE /api/salles/{}", numero);
        salleService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Room deleted successfully"));
    }

    // suppression multiple de salles
    @PostMapping("/batch-delete")
    public ResponseEntity<ApiResponse<Integer>> deleteBatch(@RequestBody List<String> numeros) {
        log.info("POST /api/salles/batch-delete - {} rooms", numeros.size());
        int deleted = salleService.deleteBatch(numeros);
        return ResponseEntity.ok(ApiResponse.success(200, deleted + " rooms deleted successfully", deleted));
    }

    // salles par lieu
    @GetMapping("/by-lieu/{codeLieu}")
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getByLieu(@PathVariable String codeLieu) {
        log.info("GET /api/salles/by-lieu/{}", codeLieu);
        List<SalleDTO> data = salleService.getByLieu(codeLieu);
        return ResponseEntity.ok(ApiResponse.success(200, "Rooms fetched successfully", data));
    }

    // salles compatibles avec un type d'evenement
    @GetMapping("/compatible")
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getCompatible(
            @RequestParam String codeLieu,
            @RequestParam String codeCategorie) {
        log.info("GET /api/salles/compatible?codeLieu={}&codeCategorie={}", codeLieu, codeCategorie);
        List<SalleDTO> data = salleService.getCompatibleSalles(codeLieu, codeCategorie);
        return ResponseEntity.ok(ApiResponse.success(200, "Compatible rooms fetched successfully", data));
    }
}
