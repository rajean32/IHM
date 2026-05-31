package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.CancelEventRequest;
import com.ihm.model.dto.EvenementDTO;
import com.ihm.service.EvenementService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/evenements")
public class EvenementController {

    private static final Logger log = LoggerFactory.getLogger(EvenementController.class);

    private final EvenementService evenementService;

    public EvenementController(EvenementService evenementService) {
        this.evenementService = evenementService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getAll(
            @RequestParam(required = false) String organisateur,
            @RequestParam(required = false) String categorie,
            @RequestParam(required = false) String statut) {
        log.info("GET /api/evenements");
        List<EvenementDTO> data;
        if (organisateur != null) {
            data = evenementService.getByOrganisateur(organisateur);
        } else if (categorie != null) {
            data = evenementService.getByCategorie(categorie);
        } else if (statut != null) {
            data = evenementService.getByStatut(statut);
        } else {
            data = evenementService.getAll();
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Events fetched successfully", data));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EvenementDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}", id);
        EvenementDTO data = evenementService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<EvenementDTO>> create(@Valid @RequestBody EvenementDTO dto) {
        log.info("POST /api/evenements - title: {}", dto.getTitre());
        EvenementDTO data = evenementService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Event created successfully", data));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<EvenementDTO>> update(@PathVariable Integer id,
                                                             @Valid @RequestBody EvenementDTO dto) {
        log.info("PUT /api/evenements/{}", id);
        EvenementDTO data = evenementService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Event updated successfully", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/evenements/{}", id);
        evenementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event deleted successfully"));
    }

    @PutMapping("/{id}/validate")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> validate(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/validate", id);
        EvenementDTO data = evenementService.validate(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event validated successfully", data));
    }

    @PutMapping("/{id}/suspend")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> suspend(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/suspend", id);
        EvenementDTO data = evenementService.suspend(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event suspended successfully", data));
    }

    @PutMapping("/{id}/resume")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> resume(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/resume", id);
        EvenementDTO data = evenementService.resume(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event resumed successfully", data));
    }

    @PutMapping("/{id}/cancel")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> cancel(@PathVariable Integer id,
                                                             @Valid @RequestBody CancelEventRequest request) {
        log.info("PUT /api/evenements/{}/cancel", id);
        EvenementDTO data = evenementService.cancel(id, request.getMotif());
        return ResponseEntity.ok(ApiResponse.success(200, "Event cancelled successfully", data));
    }
}
