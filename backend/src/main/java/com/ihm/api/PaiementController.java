package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.PaiementDTO;
import com.ihm.service.PaiementService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/paiements")
public class PaiementController {

    private static final Logger log = LoggerFactory.getLogger(PaiementController.class);

    private final PaiementService paiementService;

    public PaiementController(PaiementService paiementService) {
        this.paiementService = paiementService;
    }

    // tous les paiements
    @GetMapping
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getAll() {
        log.info("GET /api/paiements");
        List<PaiementDTO> data = paiementService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Payments fetched successfully", data));
    }

    // paiement par ID
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<PaiementDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/paiements/{}", id);
        PaiementDTO data = paiementService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment fetched successfully", data));
    }

    // creation de paiement
    @PostMapping
    public ResponseEntity<ApiResponse<PaiementDTO>> create(@Valid @RequestBody PaiementDTO dto) {
        log.info("POST /api/paiements - reservation: {}", dto.getIdReservation());
        PaiementDTO data = paiementService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Payment created successfully", data));
    }

    // modification de paiement
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<PaiementDTO>> update(@PathVariable Integer id,
                                                            @Valid @RequestBody PaiementDTO dto) {
        log.info("PUT /api/paiements/{}", id);
        PaiementDTO data = paiementService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment updated successfully", data));
    }

    // statut du paiement
    @GetMapping("/reservation/{idReservation}/status")
    public ResponseEntity<ApiResponse<PaiementDTO.PaiementStatus>> getPaymentStatus(@PathVariable Integer idReservation) {
        log.info("GET /api/paiements/reservation/{}/status", idReservation);
        PaiementDTO.PaiementStatus data = paiementService.getPaymentStatus(idReservation);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment status fetched successfully", data));
    }

    // webhook de paiement
    @PostMapping("/webhook")
    public ResponseEntity<ApiResponse<PaiementDTO.PaiementStatus>> processWebhook(
            @RequestParam String reservationId,
            @RequestParam BigDecimal amount,
            @RequestParam String modePaiement,
            @RequestParam String status) {
        log.info("POST /api/paiements/webhook - reservation: {}, status: {}", reservationId, status);
        PaiementDTO.PaiementStatus data = paiementService.processWebhook(reservationId, amount, modePaiement, status);
        return ResponseEntity.ok(ApiResponse.success(200, "Webhook processed successfully", data));
    }

    // suppression de paiement
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/paiements/{}", id);
        paiementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment deleted successfully"));
    }
}
