package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.TicketDTO;
import com.ihm.service.TicketService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/gate")
public class GateController {

    private static final Logger log = LoggerFactory.getLogger(GateController.class);

    private final TicketService ticketService;

    public GateController(TicketService ticketService) {
        this.ticketService = ticketService;
    }

    @PostMapping("/scan")
    public ResponseEntity<ApiResponse<TicketDTO.GateScanResponse>> scanTicket(@RequestBody GateScanRequest request) {
        log.info("POST /api/gate/scan - QR token: {}", request.getQrToken() != null ? request.getQrToken().substring(0, Math.min(20, request.getQrToken().length())) + "..." : "null");
        if (request.getQrToken() == null || request.getQrToken().isBlank()) {
            TicketDTO.GateScanResponse errorResp = new TicketDTO.GateScanResponse();
            errorResp.setStatut("INVALID");
            errorResp.setMessage("QR token is required");
            return ResponseEntity.badRequest().body(ApiResponse.success(400, "QR token is required", errorResp));
        }
        TicketDTO.GateScanResponse result = ticketService.scanAtGate(request.getQrToken());
        return ResponseEntity.ok(ApiResponse.success(200, "Gate scan processed", result));
    }

    public static class GateScanRequest {
        private String qrToken;

        public GateScanRequest() {}

        public String getQrToken() { return qrToken; }
        public void setQrToken(String qrToken) { this.qrToken = qrToken; }
    }
}