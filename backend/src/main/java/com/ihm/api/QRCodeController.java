package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.TicketQRResponse;
import com.ihm.model.dto.TicketValidationResponse;
import com.ihm.service.TicketService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tickets")
public class QRCodeController {

    private static final Logger log = LoggerFactory.getLogger(QRCodeController.class);

    private final TicketService ticketService;

    public QRCodeController(TicketService ticketService) {
        this.ticketService = ticketService;
    }

    @GetMapping("/{code}/qrcode")
    public ResponseEntity<ApiResponse<TicketQRResponse>> generateQRCode(@PathVariable String code) {
        log.info("GET /api/tickets/{}/qrcode", code);
        TicketQRResponse response = ticketService.generateQRCode(code);
        return ResponseEntity.ok(ApiResponse.success(200, "QR code generated successfully", response));
    }

    @PostMapping("/validate")
    public ResponseEntity<ApiResponse<TicketValidationResponse>> validateTicket(@RequestParam String codeTicket) {
        log.info("POST /api/tickets/validate?codeTicket={}", codeTicket);
        TicketValidationResponse response = ticketService.validateTicket(codeTicket);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket validation completed", response));
    }
}
