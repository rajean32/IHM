package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.SalleDTO;
import com.ihm.service.EvenementService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/evenements")
public class EvenementController {

    private static final Logger log = LoggerFactory.getLogger(EvenementController.class);

    private final EvenementService evenementService;

    public EvenementController(EvenementService evenementService) {
        this.evenementService = evenementService;
    }

    // liste des événements
    @GetMapping
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getAll(
            @RequestParam(required = false) String organisateur,
            @RequestParam(required = false) String categorie,
            @RequestParam(required = false) String statut,
            @RequestParam(required = false) String ville) {
        log.info("GET /api/evenements - ville: {}", ville);
        List<EvenementDTO> data;
        if (organisateur != null) {
            data = evenementService.getByOrganisateur(organisateur);
        } else if (categorie != null) {
            data = evenementService.getByCategorie(categorie);
        } else if (statut != null) {
            data = evenementService.getByStatut(statut);
        } else if (ville != null) {
            data = evenementService.getAllWithVillePriority(ville);
        } else {
            data = evenementService.getAll();
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Events fetched successfully", data));
    }

    // recherche d'événements
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> searchEvents(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String categorie,
            @RequestParam(required = false) String ville,
            @RequestParam(required = false) String codeLieu,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) String statut,
            @RequestParam(required = false) BigDecimal prixMin,
            @RequestParam(required = false) BigDecimal prixMax) {
        log.info("GET /api/evenements/search - q: {}, categorie: {}, lieu: {}, ville: {}, prix: {}-{}",
                q, categorie, codeLieu, ville, prixMin, prixMax);
        EvenementDTO.EventSearchRequest request = new EvenementDTO.EventSearchRequest();
        request.setQ(q);
        request.setCategorie(categorie);
        request.setVille(ville);
        request.setCodeLieu(codeLieu);
        request.setDateFrom(dateFrom);
        request.setDateTo(dateTo);
        request.setStatut(statut);
        request.setPrixMin(prixMin);
        request.setPrixMax(prixMax);
        List<EvenementDTO> results = evenementService.searchEvents(request);
        return ResponseEntity.ok(ApiResponse.success(200, "Search completed, found " + results.size() + " events", results));
    }

    // événements à venir
    @GetMapping("/upcoming")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getUpcomingEvents() {
        log.info("GET /api/evenements/upcoming");
        List<EvenementDTO> events = evenementService.getUpcomingEvents();
        return ResponseEntity.ok(ApiResponse.success(200, "Upcoming events fetched successfully", events));
    }

    // événements populaires
    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getPopularEvents() {
        log.info("GET /api/evenements/popular");
        List<EvenementDTO> events = evenementService.getPopularEvents();
        return ResponseEntity.ok(ApiResponse.success(200, "Popular events fetched successfully", events));
    }

    // détail d'un événement
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EvenementDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}", id);
        EvenementDTO data = evenementService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event fetched successfully", data));
    }

    // détail complet d'un événement
    @GetMapping("/{id}/detail")
    public ResponseEntity<ApiResponse<EvenementDTO.EventDetail>> getEventDetail(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}/detail", id);
        EvenementDTO.EventDetail detail = evenementService.getEventDetail(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event detail fetched successfully", detail));
    }

    // places disponibles
    @GetMapping("/{id}/places/available")
    public ResponseEntity<ApiResponse<List<SalleDTO.SeatingDTO>>> getAvailableSeats(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}/places/available", id);
        List<SalleDTO.SeatingDTO> seats = evenementService.getAvailableSeats(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Available seats fetched successfully", seats));
    }

    // création d'un événement
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

    // suppression d'un événement
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/evenements/{}", id);
        evenementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event deleted successfully"));
    }

    // validation d'un événement
    @PutMapping("/{id}/validate")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> validate(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/validate", id);
        EvenementDTO data = evenementService.validate(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event validated successfully", data));
    }

    // suspension d'un événement
    @PutMapping("/{id}/suspend")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> suspend(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/suspend", id);
        EvenementDTO data = evenementService.suspend(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event suspended successfully", data));
    }

    // reprise d'un événement
    @PutMapping("/{id}/resume")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> resume(@PathVariable Integer id) {
        log.info("PUT /api/evenements/{}/resume", id);
        EvenementDTO data = evenementService.resume(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event resumed successfully", data));
    }

    // upload d'image
    @PostMapping("/{id}/image")
    public ResponseEntity<ApiResponse<Void>> uploadImage(@PathVariable Integer id,
                                                          @RequestParam("file") MultipartFile file) {
        log.info("POST /api/evenements/{}/image", id);
        evenementService.uploadImage(id, file);
        return ResponseEntity.ok(ApiResponse.success(200, "Image uploaded successfully"));
    }

    // annulation d'un événement
    @PutMapping("/{id}/cancel")
    @PreAuthorize("hasRole('ADMINISTRATEUR')")
    public ResponseEntity<ApiResponse<EvenementDTO>> cancel(@PathVariable Integer id,
                                                             @Valid @RequestBody EvenementDTO.CancelEventRequest request) {
        log.info("PUT /api/evenements/{}/cancel", id);
        EvenementDTO data = evenementService.cancel(id, request.getMotif());
        return ResponseEntity.ok(ApiResponse.success(200, "Event cancelled successfully", data));
    }
}
