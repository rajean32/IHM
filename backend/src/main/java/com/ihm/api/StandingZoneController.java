package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.ZoneStandingDTO;
import com.ihm.service.StandingZoneService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/evenements/{eventId}/zones")
public class StandingZoneController {

    private static final Logger log = LoggerFactory.getLogger(StandingZoneController.class);

    private final StandingZoneService standingZoneService;

    public StandingZoneController(StandingZoneService standingZoneService) {
        this.standingZoneService = standingZoneService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ZoneStandingDTO>>> getZones(@PathVariable Integer eventId) {
        log.info("GET /api/evenements/{}/zones", eventId);
        List<ZoneStandingDTO> zones = standingZoneService.getZonesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Standing zones fetched successfully", zones));
    }

    @PostMapping
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<ZoneStandingDTO>> createZone(
            @PathVariable Integer eventId,
            @Valid @RequestBody ZoneStandingDTO dto) {
        log.info("POST /api/evenements/{}/zones - nom: {}, capacite: {}, prix: {}", eventId, dto.getNom(), dto.getCapacite(), dto.getPrix());
        ZoneStandingDTO zone = standingZoneService.createZone(eventId, dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Standing zone created successfully", zone));
    }

    @PutMapping("/{zoneId}")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<ZoneStandingDTO>> updateZone(
            @PathVariable Integer eventId,
            @PathVariable Integer zoneId,
            @Valid @RequestBody ZoneStandingDTO dto) {
        log.info("PUT /api/evenements/{}/zones/{}", eventId, zoneId);
        ZoneStandingDTO zone = standingZoneService.updateZone(zoneId, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Standing zone updated successfully", zone));
    }

    @DeleteMapping("/{zoneId}")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<Void>> deleteZone(
            @PathVariable Integer eventId,
            @PathVariable Integer zoneId) {
        log.info("DELETE /api/evenements/{}/zones/{}", eventId, zoneId);
        standingZoneService.deleteZone(zoneId);
        return ResponseEntity.ok(ApiResponse.success(200, "Standing zone deleted successfully"));
    }
}
