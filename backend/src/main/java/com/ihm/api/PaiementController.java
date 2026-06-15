package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.PaiementDTO;
import com.ihm.schema.PaiementRequestDTO;
import com.ihm.schema.PaiementResultDTO;
import com.ihm.service.NotificationService;
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
    private final NotificationService notificationService;

    public PaiementController(PaiementService paiementService,
                              NotificationService notificationService) {
        this.paiementService = paiementService;
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getAll() {
        log.info("GET /api/paiements");
        List<PaiementDTO> data = paiementService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Payments fetched successfully", data));
    }

    @GetMapping("/client/{codeClient}")
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getByClient(@PathVariable String codeClient) {
        log.info("GET /api/paiements/client/{}", codeClient);
        List<PaiementDTO> data = paiementService.getByClient(codeClient);
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

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<PaiementDTO>> update(@PathVariable Integer id,
                                                            @Valid @RequestBody PaiementDTO dto) {
        log.info("PUT /api/paiements/{}", id);
        PaiementDTO data = paiementService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment updated successfully", data));
    }

    @GetMapping("/reservation/{idReservation}/status")
    public ResponseEntity<ApiResponse<PaiementDTO.PaiementStatus>> getPaymentStatus(@PathVariable Integer idReservation) {
        log.info("GET /api/paiements/reservation/{}/status", idReservation);
        PaiementDTO.PaiementStatus data = paiementService.getPaymentStatus(idReservation);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment status fetched successfully", data));
    }

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

    // NOUVEAU: Paiement avec réduction
    @PostMapping("/process-with-reduction")
    public ResponseEntity<ApiResponse<PaiementResultDTO>> processPaymentWithReduction(@Valid @RequestBody PaiementRequestDTO request) {
        log.info("POST /api/paiements/process-with-reduction - client: {}, type: {}", 
                 request.getCodeClient(), request.getTypePaiement());
        try {
            PaiementResultDTO result = paiementService.processPaymentWithReduction(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(201, "Paiement traité", result));
        } catch (Exception e) {
            notificationService.create(
                    request.getCodeClient(),
                    "Paiement refusé",
                    "Votre paiement a été refusé : " + e.getMessage(),
                    "PAYMENT_FAILED",
                    null
            );
            throw e;
        }
    }

    // NOUVEAU: Remboursement
    @PostMapping("/rembourser/{idReservation}")
    public ResponseEntity<ApiResponse<PaiementResultDTO>> rembourserReservation(
            @PathVariable Integer idReservation,
            @RequestParam String codeClient,
            @RequestParam(defaultValue = "false") boolean isAnnulationEvenement) {
        log.info("POST /api/paiements/rembourser/{} - client: {}, annulationEvenement: {}", 
                 idReservation, codeClient, isAnnulationEvenement);
        PaiementResultDTO result = paiementService.rembourserReservation(idReservation, codeClient, isAnnulationEvenement);
        return ResponseEntity.ok(ApiResponse.success(200, "Traitement du remboursement effectué", result));
    }

    // NOUVEAU: Vérifier transaction mobile money
    @GetMapping("/transaction/verifier")
    public ResponseEntity<ApiResponse<PaiementResultDTO>> verifierTransaction(
            @RequestParam String reference,
            @RequestParam String typePaiement) {
        log.info("GET /api/paiements/transaction/verifier - ref: {}, type: {}", reference, typePaiement);
        PaiementResultDTO result = paiementService.verifierTransactionMobile(reference, typePaiement);
        return ResponseEntity.ok(ApiResponse.success(200, "Vérification effectuée", result));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/paiements/{}", id);
        paiementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Payment deleted successfully"));
    }
}