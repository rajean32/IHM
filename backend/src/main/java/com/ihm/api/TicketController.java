package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.TicketDTO;
import com.ihm.service.PDFTicketService;
import com.ihm.service.TicketService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    private static final Logger log = LoggerFactory.getLogger(TicketController.class);

    private final TicketService ticketService;
    private final PDFTicketService pdfTicketService;

    public TicketController(TicketService ticketService, PDFTicketService pdfTicketService) {
        this.ticketService = ticketService;
        this.pdfTicketService = pdfTicketService;
    }

    // tous les tickets (optionnellement filtrés par client)
    @GetMapping
    public ResponseEntity<ApiResponse<List<TicketDTO>>> getAll(
            @RequestParam(required = false) String client) {
        log.info("GET /api/tickets?client={}", client);
        List<TicketDTO> data;
        if (client != null) {
            data = ticketService.getByClient(client);
        } else {
            data = ticketService.getAll();
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Tickets fetched successfully", data));
    }

    // ticket par code
    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<TicketDTO>> getById(@PathVariable String code) {
        log.info("GET /api/tickets/{}", code);
        TicketDTO data = ticketService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket fetched successfully", data));
    }

    // creation de ticket
    @PostMapping
    public ResponseEntity<ApiResponse<TicketDTO>> create(@Valid @RequestBody TicketDTO dto) {
        log.info("POST /api/tickets - code: {}", dto.getCodeTicket());
        TicketDTO data = ticketService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Ticket created successfully", data));
    }

    // modification de ticket
    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<TicketDTO>> update(@PathVariable String code,
                                                           @Valid @RequestBody TicketDTO dto) {
        log.info("PUT /api/tickets/{}", code);
        TicketDTO data = ticketService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket updated successfully", data));
    }

    // suppression de ticket
    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/tickets/{}", code);
        ticketService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket deleted successfully"));
    }

    // generation QR code
    @GetMapping("/{code}/qrcode")
    public ResponseEntity<ApiResponse<TicketDTO.QRResponse>> getQRCode(@PathVariable String code) {
        log.info("GET /api/tickets/{}/qrcode", code);
        TicketDTO.QRResponse data = ticketService.generateQRCode(code);
        return ResponseEntity.ok(ApiResponse.success(200, "QR code generated successfully", data));
    }

    // validation de ticket
    @PostMapping("/validate")
    public ResponseEntity<ApiResponse<TicketDTO.ValidationResponse>> validateTicket(
            @RequestParam String codeTicket) {
        log.info("POST /api/tickets/validate - code: {}", codeTicket);
        TicketDTO.ValidationResponse result = ticketService.validateTicket(codeTicket);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket validated successfully", result));
    }

    // Feature 17: Liste des codes valides pour un événement (cache offline scanner)
    @GetMapping("/event/{eventId}/valid-codes")
    public ResponseEntity<ApiResponse<List<String>>> getValidCodesForEvent(@PathVariable Integer eventId) {
        log.info("GET /api/tickets/event/{}/valid-codes", eventId);
        List<String> codes = ticketService.getValidTicketCodesForEvent(eventId);
        return ResponseEntity.ok(ApiResponse.success(200, "Valid ticket codes fetched", codes));
    }

    // telechargement PDF
    @GetMapping("/{code}/pdf")
    public ResponseEntity<byte[]> downloadPDF(@PathVariable String code) {
        log.info("GET /api/tickets/{}/pdf", code);
        byte[] pdfBytes = pdfTicketService.generateTicketPDF(code);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData("filename", "ticket-" + code + ".pdf");
        return ResponseEntity.ok().headers(headers).body(pdfBytes);
    }
}
