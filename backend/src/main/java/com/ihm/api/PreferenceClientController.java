package com.ihm.api;

import com.ihm.model.PreferenceClient;
import com.ihm.schema.ApiResponse;
import com.ihm.schema.EvenementDTO;
import com.ihm.service.EvenementService;
import com.ihm.service.PreferenceClientService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/preferences")
public class PreferenceClientController {

    private static final Logger log = LoggerFactory.getLogger(PreferenceClientController.class);

    private final PreferenceClientService preferenceService;
    private final EvenementService evenementService;

    public PreferenceClientController(PreferenceClientService preferenceService,
                                       EvenementService evenementService) {
        this.preferenceService = preferenceService;
        this.evenementService = evenementService;
    }

    @GetMapping("/{codeClient}")
    public ResponseEntity<ApiResponse<List<PreferenceClient>>> getPreferences(@PathVariable String codeClient) {
        log.info("GET /api/preferences/{}", codeClient);
        return ResponseEntity.ok(ApiResponse.success(200, "Preferences fetched", preferenceService.getPreferences(codeClient)));
    }

    @PostMapping("/{codeClient}")
    public ResponseEntity<ApiResponse<PreferenceClient>> addPreference(@PathVariable String codeClient,
                                                                        @RequestBody Map<String, String> body) {
        String codeCategorie = body.get("codeCategorie");
        log.info("POST /api/preferences/{} - categorie: {}", codeClient, codeCategorie);
        PreferenceClient data = preferenceService.addPreference(codeClient, codeCategorie);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Preference added", data));
    }

    @DeleteMapping("/{codeClient}/{codeCategorie}")
    public ResponseEntity<ApiResponse<Void>> removePreference(@PathVariable String codeClient,
                                                               @PathVariable String codeCategorie) {
        log.info("DELETE /api/preferences/{}/{}", codeClient, codeCategorie);
        preferenceService.removePreference(codeClient, codeCategorie);
        return ResponseEntity.ok(ApiResponse.success(200, "Preference removed"));
    }

    @GetMapping("/{codeClient}/recommended")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getRecommended(@PathVariable String codeClient) {
        log.info("GET /api/preferences/{}/recommended", codeClient);
        List<String> codes = preferenceService.getPreferences(codeClient).stream()
                .map(PreferenceClient::getCodeCategorie)
                .toList();
        List<EvenementDTO> events = codes.stream()
                .flatMap(c -> evenementService.getByCategorie(c).stream())
                .distinct()
                .toList();
        return ResponseEntity.ok(ApiResponse.success(200, "Recommended events fetched", events));
    }
}
