package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.*;
import com.ihm.service.LieuService;
import com.ihm.service.PlaceService;
import com.ihm.service.SalleService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/organisateur/venues")
public class OrganizerVenueController {

    private static final Logger log = LoggerFactory.getLogger(OrganizerVenueController.class);

    private final LieuService lieuService;
    private final SalleService salleService;
    private final PlaceService placeService;

    public OrganizerVenueController(LieuService lieuService, SalleService salleService, PlaceService placeService) {
        this.lieuService = lieuService;
        this.salleService = salleService;
        this.placeService = placeService;
    }

    @GetMapping("/lieux")
    public ResponseEntity<ApiResponse<List<LieuDTO>>> getAllLieux() {
        log.info("GET /api/organisateur/venues/lieux");
        return ResponseEntity.ok(ApiResponse.success(200, "Lieux fetched", lieuService.getAll()));
    }

    @PostMapping("/lieux")
    public ResponseEntity<ApiResponse<LieuDTO>> createLieu(@Valid @RequestBody LieuDTO dto) {
        log.info("POST /api/organisateur/venues/lieux");
        LieuDTO data = lieuService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Lieu created", data));
    }

    @PutMapping("/lieux/{id}")
    public ResponseEntity<ApiResponse<LieuDTO>> updateLieu(@PathVariable Integer id, @Valid @RequestBody LieuDTO dto) {
        log.info("PUT /api/organisateur/venues/lieux/{}", id);
        LieuDTO data = lieuService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Lieu updated", data));
    }

    @DeleteMapping("/lieux/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteLieu(@PathVariable Integer id) {
        log.info("DELETE /api/organisateur/venues/lieux/{}", id);
        lieuService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Lieu deleted"));
    }

    @GetMapping("/salles")
    public ResponseEntity<ApiResponse<List<SalleDTO>>> getAllSalles() {
        log.info("GET /api/organisateur/venues/salles");
        return ResponseEntity.ok(ApiResponse.success(200, "Salles fetched", salleService.getAll()));
    }

    @GetMapping("/salles/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> getSalleById(@PathVariable String numero) {
        log.info("GET /api/organisateur/venues/salles/{}", numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle fetched", salleService.getById(numero)));
    }

    @PostMapping("/salles")
    public ResponseEntity<ApiResponse<SalleDTO>> createSalle(@Valid @RequestBody SalleDTO dto) {
        log.info("POST /api/organisateur/venues/salles");
        SalleDTO data = salleService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Salle created", data));
    }

    @PutMapping("/salles/{numero}")
    public ResponseEntity<ApiResponse<SalleDTO>> updateSalle(@PathVariable String numero, @Valid @RequestBody SalleDTO dto) {
        log.info("PUT /api/organisateur/venues/salles/{}", numero);
        SalleDTO data = salleService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle updated", data));
    }

    @DeleteMapping("/salles/{numero}")
    public ResponseEntity<ApiResponse<Void>> deleteSalle(@PathVariable String numero) {
        log.info("DELETE /api/organisateur/venues/salles/{}", numero);
        salleService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Salle deleted"));
    }

    @GetMapping("/places")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> getAllPlaces(@RequestParam(required = false) String salle) {
        log.info("GET /api/organisateur/venues/places");
        if (salle != null) {
            return ResponseEntity.ok(ApiResponse.success(200, "Places fetched", placeService.getBySalle(salle)));
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Places fetched", placeService.getAll()));
    }

    @PostMapping("/places")
    public ResponseEntity<ApiResponse<PlaceDTO>> createPlace(@Valid @RequestBody PlaceDTO dto) {
        log.info("POST /api/organisateur/venues/places");
        PlaceDTO data = placeService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Place created", data));
    }

    @PostMapping("/places/batch")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> createPlacesBatch(@Valid @RequestBody BatchPlaceRequest request) {
        log.info("POST /api/organisateur/venues/places/batch");
        List<PlaceDTO> data = placeService.createBatch(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(201, "Places generated", data));
    }

    @PutMapping("/places/{numero}")
    public ResponseEntity<ApiResponse<PlaceDTO>> updatePlace(@PathVariable String numero, @Valid @RequestBody PlaceDTO dto) {
        log.info("PUT /api/organisateur/venues/places/{}", numero);
        PlaceDTO data = placeService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Place updated", data));
    }

    @DeleteMapping("/places/{numero}")
    public ResponseEntity<ApiResponse<Void>> deletePlace(@PathVariable String numero) {
        log.info("DELETE /api/organisateur/venues/places/{}", numero);
        placeService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Place deleted"));
    }
}
