package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.PaiementDTO;
import com.ihm.service.PaiementService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/paiements")
public class PaiementController {

    private static final Logger log = LoggerFactory.getLogger(PaiementController.class);

    private final PaiementService paiementService;

    public PaiementController(PaiementService paiementService) {
        this.paiementService = paiementService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getAll() {
        log.info("GET /api/paiements");
        List<PaiementDTO> data = paiementService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Payments fetched successfully", data));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<PaiementDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/paiements/{}", id);
        PaiementDTO data = paiementService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PaiementDTO>> create(@Valid @RequestBody PaiementDTO dto) {
        log.info("POST /api/paiements - reservation: {}", dto.getIdReservation());
        PaiementDTO data = paiementService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Payment created successfully", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/paiements/{}", id);
        paiementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment deleted successfully"));
    }
}
