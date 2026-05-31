package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.TicketDTO;
import com.ihm.model.dto.TicketQRResponse;
import com.ihm.model.dto.TicketValidationResponse;
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

    @GetMapping
    public ResponseEntity<ApiResponse<List<TicketDTO>>> getAll() {
        log.info("GET /api/tickets");
        List<TicketDTO> data = ticketService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Tickets fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<TicketDTO>> getById(@PathVariable String code) {
        log.info("GET /api/tickets/{}", code);
        TicketDTO data = ticketService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TicketDTO>> create(@Valid @RequestBody TicketDTO dto) {
        log.info("POST /api/tickets - code: {}", dto.getCodeTicket());
        TicketDTO data = ticketService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Ticket created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<TicketDTO>> update(@PathVariable String code,
                                                           @Valid @RequestBody TicketDTO dto) {
        log.info("PUT /api/tickets/{}", code);
        TicketDTO data = ticketService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/tickets/{}", code);
        ticketService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket deleted successfully"));
    }

    @GetMapping("/{code}/qrcode")
    public ResponseEntity<ApiResponse<TicketQRResponse>> getQRCode(@PathVariable String code) {
        log.info("GET /api/tickets/{}/qrcode", code);
        TicketQRResponse data = ticketService.generateQRCode(code);
        return ResponseEntity.ok(ApiResponse.success(200, "QR code generated successfully", data));
    }

    @PostMapping("/validate")
    public ResponseEntity<ApiResponse<TicketValidationResponse>> validateTicket(
            @RequestParam String codeTicket) {
        log.info("POST /api/tickets/validate - code: {}", codeTicket);
        TicketValidationResponse result = ticketService.validateTicket(codeTicket);
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket validated successfully", result));
    }

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
