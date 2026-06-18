package com.ihm.api;

import com.ihm.model.Avis;
import com.ihm.schema.ApiResponse;
import com.ihm.service.AvisService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/avis")
public class AvisController {

    private static final Logger log = LoggerFactory.getLogger(AvisController.class);

    private final AvisService avisService;

    public AvisController(AvisService avisService) {
        this.avisService = avisService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Avis>> create(@RequestBody Map<String, Object> body) {
        Integer idEvenement = Integer.valueOf(body.get("idEvenement").toString());
        String codeClient = (String) body.get("codeClient");
        Integer note = Integer.valueOf(body.get("note").toString());
        String commentaire = (String) body.get("commentaire");
        log.info("POST /api/avis - event: {}, client: {}, note: {}", idEvenement, codeClient, note);
        Avis data = avisService.create(idEvenement, codeClient, note, commentaire);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Avis créé", data));
    }

    @GetMapping("/evenement/{idEvenement}")
    public ResponseEntity<ApiResponse<List<Avis>>> getByEvenement(@PathVariable Integer idEvenement) {
        log.info("GET /api/avis/evenement/{}", idEvenement);
        List<Avis> data = avisService.getByEvenement(idEvenement);
        return ResponseEntity.ok(ApiResponse.success(200, "Avis récupérés", data));
    }

    @GetMapping("/evenement/{idEvenement}/moyenne")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMoyenne(@PathVariable Integer idEvenement) {
        log.info("GET /api/avis/evenement/{}/moyenne", idEvenement);
        Double moyenne = avisService.getNoteMoyenne(idEvenement);
        long count = avisService.getNombreAvis(idEvenement);
        return ResponseEntity.ok(ApiResponse.success(200, "Moyenne récupérée", Map.of(
            "moyenne", moyenne != null ? moyenne : 0.0,
            "nombreAvis", count
        )));
    }
}
