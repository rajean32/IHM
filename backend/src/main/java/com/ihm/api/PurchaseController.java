package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.PurchaseRequest;
import com.ihm.service.PurchaseService;
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
    public ResponseEntity<ApiResponse<Map<String, Object>>> purchase(@RequestBody PurchaseRequest request) {
        int ticketCount = request.getTickets() != null ? request.getTickets().size() : 0;
        log.info("POST /api/achat - client: {}, {} tickets, montant: {}",
                request.getCodeClient(), ticketCount, request.getMontant());
        if (request.getTickets() != null) {
            for (int i = 0; i < request.getTickets().size(); i++) {
                var t = request.getTickets().get(i);
                log.debug("  Ticket {}: code={}, place={}, event={}, prix={}",
                        i, t.getCodeTicket(), t.getNumeroPlace(), t.getIdEvenement(), t.getPrix());
            }
        }
        Map<String, Object> result = purchaseService.processPurchase(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Purchase completed successfully", result));
    }
}
