package com.ihm.api;

import com.ihm.schema.AbonnementDTO;
import com.ihm.schema.ApiResponse;
import com.ihm.schema.EvenementDTO;
import com.ihm.service.AbonnementService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/abonnements")
public class AbonnementController {

    private static final Logger log = LoggerFactory.getLogger(AbonnementController.class);

    private final AbonnementService abonnementService;

    public AbonnementController(AbonnementService abonnementService) {
        this.abonnementService = abonnementService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AbonnementDTO>> subscribe(@RequestBody Map<String, String> body) {
        String codeClient = body.get("codeClient");
        String codeOrganisateur = body.get("codeOrganisateur");
        log.info("POST /api/abonnements - client: {}, organizer: {}", codeClient, codeOrganisateur);
        AbonnementDTO data = abonnementService.subscribe(codeClient, codeOrganisateur);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Abonnement créé", data));
    }

    @DeleteMapping("/{codeClient}/{codeOrganisateur}")
    public ResponseEntity<ApiResponse<Void>> unsubscribe(@PathVariable String codeClient,
                                                          @PathVariable String codeOrganisateur) {
        log.info("DELETE /api/abonnements/{}/{}", codeClient, codeOrganisateur);
        abonnementService.unsubscribe(codeClient, codeOrganisateur);
        return ResponseEntity.ok(ApiResponse.success(200, "Désabonnement réussi"));
    }

    @GetMapping("/{codeClient}")
    public ResponseEntity<ApiResponse<List<AbonnementDTO>>> getAbonnements(@PathVariable String codeClient) {
        log.info("GET /api/abonnements/{}", codeClient);
        List<AbonnementDTO> data = abonnementService.getAbonnements(codeClient);
        return ResponseEntity.ok(ApiResponse.success(200, "Abonnements récupérés", data));
    }

    @GetMapping("/{codeClient}/feed")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getFeed(@PathVariable String codeClient) {
        log.info("GET /api/abonnements/{}/feed", codeClient);
        List<EvenementDTO> data = abonnementService.getFeed(codeClient);
        return ResponseEntity.ok(ApiResponse.success(200, "Feed récupéré", data));
    }
}
