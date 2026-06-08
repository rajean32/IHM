package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.LieuDTO;
import com.ihm.schema.OrganisateurDTO;
import com.ihm.schema.PlaceDTO;
import com.ihm.schema.ReservationDTO;
import com.ihm.schema.SalleDTO;
import com.ihm.model.Salle;
import com.ihm.service.LieuService;
import com.ihm.service.OrganisateurService;
import com.ihm.service.PlaceService;
import com.ihm.service.SalleService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class OrganisateurController {

    private static final Logger log = LoggerFactory.getLogger(OrganisateurController.class);

    private final OrganisateurService organisateurService;
    private final LieuService lieuService;
    private final SalleService salleService;
    private final PlaceService placeService;

    public OrganisateurController(OrganisateurService organisateurService,
                                  LieuService lieuService,
                                  SalleService salleService,
                                  PlaceService placeService) {
        this.organisateurService = organisateurService;
        this.lieuService = lieuService;
        this.salleService = salleService;
        this.placeService = placeService;
    }

    // liste des organisateurs
    @GetMapping("/organisateurs")
    public ResponseEntity<ApiResponse<List<OrganisateurDTO>>> getAll() {
        log.info("GET /api/organisateurs");
        List<OrganisateurDTO> data = organisateurService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateurs fetched successfully", data));
    }

    // détail d'un organisateur
    @GetMapping("/organisateurs/{code}")
    public ResponseEntity<ApiResponse<OrganisateurDTO>> getById(@PathVariable String code) {
        log.info("GET /api/organisateurs/{}", code);
        OrganisateurDTO data = organisateurService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur fetched successfully", data));
    }

    // création d'un organisateur
    @PostMapping("/organisateurs")
    public ResponseEntity<ApiResponse<OrganisateurDTO>> create(@Valid @RequestBody OrganisateurDTO dto) {
        log.info("POST /api/organisateurs - email: {}", dto.getEmail());
        OrganisateurDTO data = organisateurService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Organisateur created successfully", data));
    }

    // modification d'un organisateur
    @PutMapping("/organisateurs/{code}")
    public ResponseEntity<ApiResponse<OrganisateurDTO>> update(@PathVariable String code,
                                                                @Valid @RequestBody OrganisateurDTO dto) {
        log.info("PUT /api/organisateurs/{}", code);
        OrganisateurDTO data = organisateurService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur updated successfully", data));
    }

    // suppression d'un organisateur
    @DeleteMapping("/organisateurs/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/organisateurs/{}", code);
        organisateurService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Organisateur deleted successfully"));
    }

    // places d'un événement
    @GetMapping("/organisateur/evenements/{eventId}/places")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> getEventPlaces(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/places", eventId);
        List<PlaceDTO> places = organisateurService.getPlacesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Places fetched successfully", places));
    }

    // salles d'un événement
    @GetMapping("/organisateur/evenements/{eventId}/salles")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<Salle>>> getEventSalles(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/salles", eventId);
        List<Salle> salles = organisateurService.getSallesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Salles fetched successfully", salles));
    }

    // rangs d'une salle
    @GetMapping("/organisateur/evenements/{eventId}/rangs")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<String>>> getDistinctRangs(
            @PathVariable Integer eventId,
            @RequestParam String salle) {
        log.info("GET /api/organisateur/evenements/{}/rangs?salle={}", eventId, salle);
        List<String> rangs = organisateurService.getDistinctRangsForEvent(eventId, salle);
        return ResponseEntity.ok(ApiResponse.success(200, "Rangs fetched successfully", rangs));
    }

    // configuration des places
    @GetMapping("/organisateur/evenements/{eventId}/places/config")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<EvenementDTO.EventPlaceConfig>>> getPlacesWithConfig(
            @PathVariable Integer eventId,
            @RequestParam(required = false) String salle) {
        log.info("GET /api/organisateur/evenements/{}/places/config?salle={}", eventId, salle);
        List<EvenementDTO.EventPlaceConfig> places = organisateurService.getPlacesWithConfig(eventId, salle);
        return ResponseEntity.ok(ApiResponse.success(200, "Places with config fetched", places));
    }

    // recherche de places configurées
    @GetMapping("/organisateur/evenements/{eventId}/places/config/search")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<EvenementDTO.EventPlaceConfig>>> searchPlaces(
            @PathVariable Integer eventId,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String type) {
        log.info("GET /api/organisateur/evenements/{}/places/config/search?q={}&type={}", eventId, q, type);
        List<EvenementDTO.EventPlaceConfig> result = organisateurService.searchPlaces(eventId, q, type);
        return ResponseEntity.ok(ApiResponse.success(200, "Search results", result));
    }

    // types de places distincts
    @GetMapping("/organisateur/evenements/{eventId}/places/config/types")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<String>>> getDistinctTypes(
            @PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/places/config/types", eventId);
        List<String> types = organisateurService.getDistinctTypesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Distinct types fetched", types));
    }

    // tarification par rangée
    @PutMapping("/organisateur/evenements/{eventId}/places/rang/pricing")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> applyRowPricing(
            @PathVariable Integer eventId,
            @Valid @RequestBody PlaceDTO.RowPricingRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/rang/pricing - rang: {}", eventId, request.getRang());
        int updated = organisateurService.applyRowPricingWithConfig(eventId, request.getRang(),
                request.getTypePlace(), request.getPrix());
        return ResponseEntity.ok(ApiResponse.success(200, "Row pricing applied",
                Map.of("updated", updated, "rang", request.getRang(), "typePlace", request.getTypePlace())));
    }

    // tarification directe d'une place (nécessite eventId)
    @PutMapping("/organisateur/places/{numeroPlace}/pricing")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO.EventPlaceConfig>> updatePlacePricing(
            @PathVariable String numeroPlace,
            @RequestParam Integer eventId,
            @RequestParam(required = false) String typePlace,
            @RequestParam(required = false) BigDecimal prix) {
        log.info("PUT /api/organisateur/places/{}/pricing?eventId={} - type: {}, prix: {}", numeroPlace, eventId, typePlace, prix);
        if (typePlace == null && prix == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, "Bad Request", "At least typePlace or prix must be provided"));
        }
        EvenementDTO.EventPlaceConfig result = organisateurService.updatePlacePricingWithConfig(
                eventId, numeroPlace, typePlace, prix);
        return ResponseEntity.ok(ApiResponse.success(200, "Place pricing updated", result));
    }

    // mise à jour d'une place configurée
    @PutMapping("/organisateur/evenements/{eventId}/places/config/{numeroPlace}")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO.EventPlaceConfig>> updateSinglePlaceConfig(
            @PathVariable Integer eventId,
            @PathVariable String numeroPlace,
            @RequestParam(required = false) String typePlace,
            @RequestParam(required = false) BigDecimal prix) {
        log.info("PUT /api/organisateur/evenements/{}/places/config/{} - type: {}, prix: {}",
                eventId, numeroPlace, typePlace, prix);
        EvenementDTO.EventPlaceConfig result = organisateurService.updatePlacePricingWithConfig(
                eventId, numeroPlace, typePlace, prix);
        return ResponseEntity.ok(ApiResponse.success(200, "Place config updated", result));
    }

    // tarification par type de place
    @PutMapping("/organisateur/evenements/{eventId}/places/type/pricing")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> applyTypePricing(
            @PathVariable Integer eventId,
            @Valid @RequestBody PlaceDTO.TypePricingRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/type/pricing - type: {}, prix: {}",
                eventId, request.getTypePlace(), request.getPrix());
        int updated = organisateurService.applyTypePricing(eventId, request.getTypePlace(), request.getPrix());
        return ResponseEntity.ok(ApiResponse.success(200, "Type pricing applied",
                Map.of("updated", updated, "typePlace", request.getTypePlace())));
    }

    // affectation d'un type à des places
    @PutMapping("/organisateur/evenements/{eventId}/places/assign-type")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> assignTypeToPlaces(
            @PathVariable Integer eventId,
            @Valid @RequestBody PlaceDTO.TypeAssignRequest request) {
        log.info("PUT /api/organisateur/evenements/{}/places/assign-type - type: {}, places: {}, rows: {}",
                eventId, request.getTypePlace(), request.getPlaceIds(), request.getRows());
        int updated = organisateurService.assignTypeToPlaces(
                eventId, request.getTypePlace(), request.getPlaceIds(), request.getRows());
        return ResponseEntity.ok(ApiResponse.success(200, "Type assigned to places",
                Map.of("updated", updated, "typePlace", request.getTypePlace())));
    }

    // liste des lieux
    @GetMapping("/organisateur/venues/lieux")
    public ResponseEntity<ApiResponse<List<LieuDTO>>> getAllLieux() {
        log.info("GET /api/organisateur/venues/lieux");
        return ResponseEntity.ok(ApiResponse.success(200, "Lieux fetched", lieuService.getAll()));
    }

    // création d'un lieu
    @PostMapping("/organisateur/venues/lieux")
    public ResponseEntity<ApiResponse<LieuDTO>> createLieu(@Valid @RequestBody LieuDTO dto) {
        log.info("POST /api/organisateur/venues/lieux");
        LieuDTO data = lieuService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Lieu created", data));
    }

    // modification d'un lieu
    @PutMapping("/organisateur/venues/lieux/{id}")
    public ResponseEntity<ApiResponse<LieuDTO>> updateLieu(@PathVariable String id, @Valid @RequestBody LieuDTO dto) {
        log.info("PUT /api/organisateur/venues/lieux/{}", id);
        LieuDTO data = lieuService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Lieu updated", data));
    }

    // suppression d'un lieu
    @DeleteMapping("/organisateur/venues/lieux/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteLieu(@PathVariable String id) {
        log.info("DELETE /api/organisateur/venues/lieux/{}", id);
        lieuService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Lieu deleted"));
    }

    // liste des salles
    @GetMapping("/organisateur/venues/salles")
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getAllSalles() {
        log.info("GET /api/organisateur/venues/salles");
        return ResponseEntity.ok(ApiResponse.success(200, "Salles fetched", salleService.getAll()));
    }

    // détail d'une salle
    @GetMapping("/organisateur/venues/salles/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> getSalleById(@PathVariable String numero) {
        log.info("GET /api/organisateur/venues/salles/{}", numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle fetched", salleService.getById(numero)));
    }

    // création d'une salle
    @PostMapping("/organisateur/venues/salles")
    public ResponseEntity<ApiResponse<SalleDTO>> createSalle(@Valid @RequestBody SalleDTO dto) {
        log.info("POST /api/organisateur/venues/salles");
        SalleDTO data = salleService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Salle created", data));
    }

    // modification d'une salle
    @PutMapping("/organisateur/venues/salles/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> updateSalle(@PathVariable String numero, @Valid @RequestBody SalleDTO dto) {
        log.info("PUT /api/organisateur/venues/salles/{}", numero);
        SalleDTO data = salleService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle updated", data));
    }

    // suppression d'une salle
    @DeleteMapping("/organisateur/venues/salles/{numero}")
    public ResponseEntity<ApiResponse<Void>> deleteSalle(@PathVariable String numero) {
        log.info("DELETE /api/organisateur/venues/salles/{}", numero);
        salleService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle deleted"));
    }

    // liste des places
    @GetMapping("/organisateur/venues/places")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> getAllPlaces(@RequestParam(required = false) String salle) {
        log.info("GET /api/organisateur/venues/places");
        if (salle != null) {
            return ResponseEntity.ok(ApiResponse.success(200, "Places fetched", placeService.getBySalle(salle)));
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Places fetched", placeService.getAll()));
    }

    // création d'une place
    @PostMapping("/organisateur/venues/places")
    public ResponseEntity<ApiResponse<PlaceDTO>> createPlace(@Valid @RequestBody PlaceDTO dto) {
        log.info("POST /api/organisateur/venues/places");
        PlaceDTO data = placeService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Place created", data));
    }

    // création groupée de places
    @PostMapping("/organisateur/venues/places/batch")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> createPlacesBatch(@Valid @RequestBody PlaceDTO.BatchPlaceRequest request) {
        log.info("POST /api/organisateur/venues/places/batch");
        List<PlaceDTO> data = placeService.createBatch(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Places generated", data));
    }

    // modification d'une place
    @PutMapping("/organisateur/venues/places/{numero}")
    public ResponseEntity<ApiResponse<PlaceDTO>> updatePlace(@PathVariable String numero, @Valid @RequestBody PlaceDTO dto) {
        log.info("PUT /api/organisateur/venues/places/{}", numero);
        PlaceDTO data = placeService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Place updated", data));
    }

    // suppression d'une place
    @DeleteMapping("/organisateur/venues/places/{numero}")
    public ResponseEntity<ApiResponse<Void>> deletePlace(@PathVariable String numero) {
        log.info("DELETE /api/organisateur/venues/places/{}", numero);
        placeService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Place deleted"));
    }

    // ========== Ticket & Reservation Management ==========

    // tickets d'un événement
    @GetMapping("/organisateur/evenements/{eventId}/tickets")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getEventTickets(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/tickets", eventId);
        List<Map<String, Object>> data = organisateurService.getTicketsForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Tickets fetched successfully", data));
    }

    // réservations d'un événément
    @GetMapping("/organisateur/evenements/{eventId}/reservations")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getEventReservations(@PathVariable Integer eventId) {
        log.info("GET /api/organisateur/evenements/{}/reservations", eventId);
        List<Map<String, Object>> data = organisateurService.getReservationsForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservations fetched successfully", data));
    }

    // détail d'une réservation
    @GetMapping("/organisateur/reservations/{id}")
    @PreAuthorize("hasRole('ORGANISATEUR')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getReservationDetail(@PathVariable Integer id) {
        log.info("GET /api/organisateur/reservations/{}", id);
        Map<String, Object> data = organisateurService.getReservationDetail(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation detail fetched successfully", data));
    }
}
