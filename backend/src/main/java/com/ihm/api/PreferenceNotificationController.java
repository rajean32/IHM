package com.ihm.api;

import com.ihm.model.PreferenceNotification;
import com.ihm.schema.ApiResponse;
import com.ihm.service.PreferenceNotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications/preferences")
public class PreferenceNotificationController {

    private static final Logger log = LoggerFactory.getLogger(PreferenceNotificationController.class);

    private final PreferenceNotificationService service;

    public PreferenceNotificationController(PreferenceNotificationService service) {
        this.service = service;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<List<PreferenceNotification>>> getPreferences(@PathVariable String userId) {
        log.info("GET /api/notifications/preferences/{}", userId);
        return ResponseEntity.ok(ApiResponse.success(200, "Preferences fetched", service.getPreferences(userId)));
    }

    @PutMapping("/{userId}")
    public ResponseEntity<ApiResponse<PreferenceNotification>> setPreference(
            @PathVariable String userId, @RequestBody Map<String, Object> body) {
        String type = (String) body.get("typeNotification");
        String canal = (String) body.get("canal");
        boolean actif = Boolean.TRUE.equals(body.get("actif"));
        log.info("PUT /api/notifications/preferences/{} - {} / {} = {}", userId, type, canal, actif);
        PreferenceNotification pref = service.setPreference(userId, type, canal, actif);
        return ResponseEntity.ok(ApiResponse.success(200, "Preference updated", pref));
    }
}
