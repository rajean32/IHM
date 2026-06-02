package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.EventPlaceConfigDTO;
import com.ihm.model.dto.PlaceDTO;
import com.ihm.model.dto.RowPricingRequest;
import com.ihm.model.dto.TypeAssignRequest;
import com.ihm.model.dto.TypePricingRequest;
import com.ihm.schemat.Salle;
import com.ihm.service.EventPricingService;
import com.ihm.service.OrganizerPricingService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/organisateur")
@PreAuthorize("hasRole('ORGANISATEUR')")
public class OrganizerPricingController {

    private static final Logger log = LoggerFactory.getLogger(OrganizerPricingController.class);

    private final OrganizerPricingService organizerPricingService;
    private final EventPricingService eventPricingService;

    public OrganizerPricingController(OrganizerPricingService organizerPricingService,
                                      EventPricingService eventPricingService) {
        this.organizerPricingService = organizerPricingService;
        this.eventPricingService = eventPricingService;
    }

    @PutMapping("/evenements/{eventId}/places/rang/pricing")
    public ResponseEntity<ApiResponse<Map<String, Object>>> applyRowPricing(
            @PathVariable Integer eventId,
            @Valid @RequestBody RowPricingRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/rang/pricing - rang: {}", eventId, request.getRang());
        int updated = eventPricingService.applyRowPricing(eventId, request.getRang(),
                request.getTypePlace(), request.getPrix());
        return ResponseEntity.ok(ApiResponse.success(200, "Row pricing applied",
                Map.of("updated", updated, "rang", request.getRang(), "typePlace", request.getTypePlace())));
    }

    @PutMapping("/places/{numeroPlace}/pricing")
    public ResponseEntity<ApiResponse<PlaceDTO>> updatePlacePricing(
            @PathVariable String numeroPlace,
            @RequestParam(required = false) String typePlace,
            @RequestParam(required = false) BigDecimal prix) {
        log.info("PUT /api/organisateur/places/{}/pricing - type: {}, prix: {}", numeroPlace, typePlace, prix);
        if (typePlace == null && prix == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, "Bad Request", "At least typePlace or prix must be provided"));
        }
        PlaceDTO result = organizerPricingService.updatePlacePricing(numeroPlace, typePlace, prix);
        return ResponseEntity.ok(ApiResponse.success(200, "Place pricing updated", result));
    }

    @GetMapping("/evenements/{eventId}/places")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> getEventPlaces(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/places", eventId);
        List<PlaceDTO> places = organizerPricingService.getPlacesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Places fetched successfully", places));
    }

    @GetMapping("/evenements/{eventId}/salles")
    public ResponseEntity<ApiResponse<List<Salle>>> getEventSalles(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/salles", eventId);
        List<Salle> salles = eventPricingService.getSallesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Salles fetched successfully", salles));
    }

    @GetMapping("/evenements/{eventId}/rangs")
    public ResponseEntity<ApiResponse<List<String>>> getDistinctRangs(
            @PathVariable Integer eventId,
            @RequestParam String salle) {
        log.info("GET /api/organisateur/evenements/{}/rangs?salle={}", eventId, salle);
        List<String> rangs = eventPricingService.getDistinctRangsForSalle(salle);
        return ResponseEntity.ok(ApiResponse.success(200, "Rangs fetched successfully", rangs));
    }

    @GetMapping("/evenements/{eventId}/places/config")
    public ResponseEntity<ApiResponse<List<EventPlaceConfigDTO>>> getPlacesWithConfig(
            @PathVariable Integer eventId,
            @RequestParam(required = false) String salle) {
        log.info("GET /api/organisateur/evenements/{}/places/config?salle={}", eventId, salle);
        List<EventPlaceConfigDTO> places = eventPricingService.getPlacesWithConfig(eventId, salle);
        return ResponseEntity.ok(ApiResponse.success(200, "Places with config fetched", places));
    }

    @PutMapping("/evenements/{eventId}/places/config/{numeroPlace}")
    public ResponseEntity<ApiResponse<EventPlaceConfigDTO>> updateSinglePlaceConfig(
            @PathVariable Integer eventId,
            @PathVariable String numeroPlace,
            @RequestParam(required = false) String typePlace,
            @RequestParam(required = false) BigDecimal prix) {
        log.info("PUT /api/organisateur/evenements/{}/places/config/{} - type: {}, prix: {}",
                eventId, numeroPlace, typePlace, prix);
        EventPlaceConfigDTO result = eventPricingService.updatePlacePricing(
                eventId, numeroPlace, typePlace, prix);
        return ResponseEntity.ok(ApiResponse.success(200, "Place config updated", result));
    }

    @GetMapping("/evenements/{eventId}/places/config/search")
    public ResponseEntity<ApiResponse<List<EventPlaceConfigDTO>>> searchPlaces(
            @PathVariable Integer eventId,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String type) {
        log.info("GET /api/organisateur/evenements/{}/places/config/search?q={}&type={}", eventId, q, type);
        List<EventPlaceConfigDTO> result = eventPricingService.searchPlaces(eventId, q, type);
        return ResponseEntity.ok(ApiResponse.success(200, "Search results", result));
    }

    @GetMapping("/evenements/{eventId}/places/config/types")
    public ResponseEntity<ApiResponse<List<String>>> getDistinctTypes(
            @PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/places/config/types", eventId);
        List<String> types = eventPricingService.getDistinctTypesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Distinct types fetched", types));
    }

    @PutMapping("/evenements/{eventId}/places/type/pricing")
    public ResponseEntity<ApiResponse<Map<String, Object>>> applyTypePricing(
            @PathVariable Integer eventId,
            @Valid @RequestBody TypePricingRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/type/pricing - type: {}, prix: {}",
                eventId, request.getTypePlace(), request.getPrix());
        int updated = eventPricingService.applyTypePricing(eventId, request.getTypePlace(), request.getPrix());
        return ResponseEntity.ok(ApiResponse.success(200, "Type pricing applied",
                Map.of("updated", updated, "typePlace", request.getTypePlace())));
    }

    @PutMapping("/evenements/{eventId}/places/assign-type")
    public ResponseEntity<ApiResponse<Map<String, Object>>> assignTypeToPlaces(
            @PathVariable Integer eventId,
            @Valid @RequestBody TypeAssignRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/assign-type - type: {}, places: {}, rows: {}",
                eventId, request.getTypePlace(), request.getPlaceIds(), request.getRows());
        int updated = eventPricingService.assignTypeToPlaces(
                eventId, request.getTypePlace(), request.getPlaceIds(), request.getRows());
        return ResponseEntity.ok(ApiResponse.success(200, "Type assigned to places",
                Map.of("updated", updated, "typePlace", request.getTypePlace())));
    }
}
