package com.ihm.api;

import com.ihm.model.Annonce;
import com.ihm.schema.ApiResponse;
import com.ihm.service.AnnonceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/annonces")
public class AnnonceController {

    private static final Logger log = LoggerFactory.getLogger(AnnonceController.class);

    private final AnnonceService annonceService;

    public AnnonceController(AnnonceService annonceService) {
        this.annonceService = annonceService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Annonce>> create(@RequestBody Map<String, Object> body) {
        Integer idEvenement = Integer.valueOf(body.get("idEvenement").toString());
        String titre = (String) body.get("titre");
        String message = (String) body.get("message");
        String codeOrganisateur = (String) body.get("codeOrganisateur");
        log.info("POST /api/annonces - event: {}, titre: {}", idEvenement, titre);
        Annonce data = annonceService.create(idEvenement, titre, message, codeOrganisateur);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Annonce créée", data));
    }

    @GetMapping("/evenement/{idEvenement}")
    public ResponseEntity<ApiResponse<List<Annonce>>> getByEvenement(@PathVariable Integer idEvenement) {
        log.info("GET /api/annonces/evenement/{}", idEvenement);
        List<Annonce> data = annonceService.getByEvenement(idEvenement);
        return ResponseEntity.ok(ApiResponse.success(200, "Annonces récupérées", data));
    }
}
