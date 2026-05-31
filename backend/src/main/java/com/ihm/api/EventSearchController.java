package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.EventDetailDTO;
import com.ihm.model.dto.EventSearchRequest;
import com.ihm.model.dto.EvenementDTO;
import com.ihm.model.dto.SeatingDTO;
import com.ihm.service.EventSearchService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/evenements")
public class EventSearchController {

    private static final Logger log = LoggerFactory.getLogger(EventSearchController.class);

    private final EventSearchService eventSearchService;

    public EventSearchController(EventSearchService eventSearchService) {
        this.eventSearchService = eventSearchService;
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> searchEvents(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String categorie,
            @RequestParam(required = false) String ville,
            @RequestParam(required = false) Integer idLieu,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) String statut,
            @RequestParam(required = false) BigDecimal prixMin,
            @RequestParam(required = false) BigDecimal prixMax) {
        log.info("GET /api/evenements/search - q: {}, categorie: {}, lieu: {}, ville: {}, prix: {}-{}",
                q, categorie, idLieu, ville, prixMin, prixMax);
        EventSearchRequest request = new EventSearchRequest();
        request.setQ(q);
        request.setCategorie(categorie);
        request.setVille(ville);
        request.setIdLieu(idLieu);
        request.setDateFrom(dateFrom);
        request.setDateTo(dateTo);
        request.setStatut(statut);
        request.setPrixMin(prixMin);
        request.setPrixMax(prixMax);
        List<EvenementDTO> results = eventSearchService.searchEvents(request);
        return ResponseEntity.ok(ApiResponse.success(200, "Search completed, found " + results.size() + " events", results));
    }

    @GetMapping("/upcoming")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getUpcomingEvents() {
        log.info("GET /api/evenements/upcoming");
        List<EvenementDTO> events = eventSearchService.getUpcomingEvents();
        return ResponseEntity.ok(ApiResponse.success(200, "Upcoming events fetched successfully", events));
    }

    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<List<EvenementDTO>>> getPopularEvents() {
        log.info("GET /api/evenements/popular");
        List<EvenementDTO> events = eventSearchService.getPopularEvents();
        return ResponseEntity.ok(ApiResponse.success(200, "Popular events fetched successfully", events));
    }

    @GetMapping("/{id}/detail")
    public ResponseEntity<ApiResponse<EventDetailDTO>> getEventDetail(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}/detail", id);
        EventDetailDTO detail = eventSearchService.getEventDetail(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event detail fetched successfully", detail));
    }

    @GetMapping("/{id}/places/available")
    public ResponseEntity<ApiResponse<List<SeatingDTO>>> getAvailableSeats(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}/places/available", id);
        List<SeatingDTO> seats = eventSearchService.getAvailableSeats(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Available seats fetched successfully", seats));
    }
}
