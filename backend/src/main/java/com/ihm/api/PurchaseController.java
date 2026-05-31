package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.PurchaseRequest;
import com.ihm.schemat.Reservation;
import com.ihm.service.PurchaseService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/achat")
public class PurchaseController {

    private static final Logger log = LoggerFactory.getLogger(PurchaseController.class);

    private final PurchaseService purchaseService;

    public PurchaseController(PurchaseService purchaseService) {
        this.purchaseService = purchaseService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> purchase(@Valid @RequestBody PurchaseRequest request) {
        log.info("POST /api/achat - client: {}, tickets: {}", request.getCodeClient(), request.getTickets().size());
        Reservation reservation = purchaseService.processPurchase(request);
        Map<String, Object> result = Map.of(
            "idReservation", reservation.getIdReservation(),
            "dateReservation", reservation.getDateReservation().toString(),
            "codeClient", reservation.getClient().getCodeUtilisateur(),
            "status", "CONFIRMED"
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Purchase completed successfully", result));
    }
}
