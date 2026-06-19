package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.VilleDTO;
import com.ihm.service.VilleService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/villes")
public class VilleController {

    private static final Logger log = LoggerFactory.getLogger(VilleController.class);
    private final VilleService villeService;

    public VilleController(VilleService villeService) {
        this.villeService = villeService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<VilleDTO>>> getAll(
            @RequestParam(required = false) String search) {
        log.debug("GET /api/villes?search={}", search);
        List<VilleDTO> villes = search != null && !search.isBlank()
                ? villeService.search(search)
                : villeService.getAllActive();
        return ResponseEntity.ok(ApiResponse.success(200, "List of cities", villes));
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMINISTRATEUR', 'ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<VilleDTO>>> getAllAdmin() {
        log.debug("GET /api/villes/all");
        return ResponseEntity.ok(ApiResponse.success(200, "All cities", villeService.getAll()));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<VilleDTO>> getByCode(@PathVariable String code) {
        log.debug("GET /api/villes/{}", code);
        return ResponseEntity.ok(ApiResponse.success(200, "City found", villeService.getByCode(code)));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<VilleDTO>> create(@Valid @RequestBody VilleDTO dto) {
        log.info("POST /api/villes - body: {}", dto.getNom());
        return ResponseEntity.ok(ApiResponse.success(201, "City created", villeService.create(dto)));
    }

    @PutMapping("/{code}")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<VilleDTO>> update(@PathVariable String code, @Valid @RequestBody VilleDTO dto) {
        log.info("PUT /api/villes/{}", code);
        return ResponseEntity.ok(ApiResponse.success(200, "City updated", villeService.update(code, dto)));
    }

    @DeleteMapping("/{code}")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/villes/{}", code);
        villeService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "City deleted", null));
    }

    @PostMapping("/seed")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<String>> reseed() {
        log.info("POST /api/villes/seed");
        villeService.reseed();
        return ResponseEntity.ok(ApiResponse.success(200, "Cities reseeded successfully", null));
    }
}
