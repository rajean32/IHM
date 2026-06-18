package com.ihm.api;

import com.ihm.model.Reduction;
import com.ihm.schema.ApiResponse;
import com.ihm.service.ReductionService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reductions")
public class ReductionController {

    private static final Logger log = LoggerFactory.getLogger(ReductionController.class);

    private final ReductionService reductionService;

    public ReductionController(ReductionService reductionService) {
        this.reductionService = reductionService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Reduction>>> getAll() {
        log.info("GET /api/reductions");
        return ResponseEntity.ok(ApiResponse.success(200, "Réductions récupérées", reductionService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Reduction>> getById(@PathVariable Long id) {
        log.info("GET /api/reductions/{}", id);
        return ResponseEntity.ok(ApiResponse.success(200, "Réduction récupérée", reductionService.getById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Reduction>> create(@Valid @RequestBody Reduction reduction) {
        log.info("POST /api/reductions");
        Reduction created = reductionService.create(reduction);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Réduction créée", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Reduction>> update(@PathVariable Long id, @Valid @RequestBody Reduction reduction) {
        log.info("PUT /api/reductions/{}", id);
        Reduction updated = reductionService.update(id, reduction);
        return ResponseEntity.ok(ApiResponse.success(200, "Réduction mise à jour", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        log.info("DELETE /api/reductions/{}", id);
        reductionService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Réduction supprimée"));
    }

    @PostMapping("/verifier")
    public ResponseEntity<ApiResponse<Object>> verifierCodePromo(@RequestParam String code, @RequestParam Integer idEvenement) {
        log.info("POST /api/reductions/verifier - code: {}, event: {}", code, idEvenement);
        Reduction reduction = reductionService.getByCode(code);
        if (reduction == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, "Code promo introuvable", "NOT_FOUND"));
        }
        if (Boolean.FALSE.equals(reduction.isActif())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(400, "Ce code promo n'est plus actif", "INACTIVE"));
        }
        if (reduction.getDateDebut() != null && reduction.getDateDebut().isAfter(java.time.LocalDateTime.now())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(400, "Ce code promo n'est pas encore valide", "NOT_YET_VALID"));
        }
        if (reduction.getDateFin() != null && reduction.getDateFin().isBefore(java.time.LocalDateTime.now())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(400, "Ce code promo a expiré", "EXPIRED"));
        }
        if (reduction.getUtilisationMax() != null && reduction.getUtilisationCount() >= reduction.getUtilisationMax()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(400, "Ce code promo a atteint sa limite d'utilisations", "LIMIT_REACHED"));
        }
        if (reduction.getEvenement() != null && !reduction.getEvenement().getIdEvenement().equals(idEvenement)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(400, "Ce code promo n'est pas valide pour cet événement", "WRONG_EVENT"));
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Code promo valide", reduction));
    }
}