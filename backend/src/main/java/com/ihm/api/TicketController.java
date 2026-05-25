package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.TicketDTO;
import com.ihm.service.TicketService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    private static final Logger log = LoggerFactory.getLogger(TicketController.class);

    private final TicketService ticketService;

    public TicketController(TicketService ticketService) {
        this.ticketService = ticketService;
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
}
