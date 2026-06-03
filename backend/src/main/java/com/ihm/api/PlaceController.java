package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.PlaceDTO;
import com.ihm.service.PlaceService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/places")
public class PlaceController {

    private static final Logger log = LoggerFactory.getLogger(PlaceController.class);

    private final PlaceService placeService;

    public PlaceController(PlaceService placeService) {
        this.placeService = placeService;
    }

    // toutes les places
    @GetMapping
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> getAll(
            @RequestParam(required = false) String salle) {
        log.info("GET /api/places");
        List<PlaceDTO> data;
        if (salle != null) {
            data = placeService.getBySalle(salle);
        } else {
            data = placeService.getAll();
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Places fetched successfully", data));
    }

    // place par numero
    @GetMapping("/{numero}")
    public ResponseEntity<ApiResponse<PlaceDTO>> getById(@PathVariable String numero) {
        log.info("GET /api/places/{}", numero);
        PlaceDTO data = placeService.getById(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Place fetched successfully", data));
    }

    // creation de place
    @PostMapping
    public ResponseEntity<ApiResponse<PlaceDTO>> create(@Valid @RequestBody PlaceDTO dto) {
        log.info("POST /api/places - numero: {}", dto.getNumeroPlace());
        PlaceDTO data = placeService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Place created successfully", data));
    }

    // generation par lot
    @PostMapping("/batch")
    public ResponseEntity<ApiResponse<List<PlaceDTO>>> createBatch(@Valid @RequestBody PlaceDTO.BatchPlaceRequest request) {
        log.info("POST /api/places/batch - salle: {}, rangees: {}, parRangee: {}",
                request.getNumeroSalle(), request.getNombreRangees(), request.getPlacesParRangee());
        List<PlaceDTO> data = placeService.createBatch(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, data.size() + " places created successfully", data));
    }

    // modification de place
    @PutMapping("/{numero}")
    public ResponseEntity<ApiResponse<PlaceDTO>> update(@PathVariable String numero, @Valid @RequestBody PlaceDTO dto) {
        log.info("PUT /api/places/{}", numero);
        PlaceDTO data = placeService.update(numero, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Place updated successfully", data));
    }

    // suppression de place
    @DeleteMapping("/{numero}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String numero) {
        log.info("DELETE /api/places/{}", numero);
        placeService.delete(numero);
        return ResponseEntity.ok(ApiResponse.success(200, "Place deleted successfully"));
    }
}
