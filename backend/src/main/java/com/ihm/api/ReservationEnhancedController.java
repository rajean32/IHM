package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ReservationCancelResponse;
import com.ihm.model.dto.ReservationDTO;
import com.ihm.model.dto.TicketDTO;
import com.ihm.repository.CorrespondARepository;
import com.ihm.service.ReservationService;
import com.ihm.service.TicketService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reservations")
public class ReservationEnhancedController {

    private static final Logger log = LoggerFactory.getLogger(ReservationEnhancedController.class);

    private final ReservationService reservationService;
    private final TicketService ticketService;
    private final CorrespondARepository correspondARepository;

    public ReservationEnhancedController(ReservationService reservationService,
                                         TicketService ticketService,
                                         CorrespondARepository correspondARepository) {
        this.reservationService = reservationService;
        this.ticketService = ticketService;
        this.correspondARepository = correspondARepository;
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ReservationDTO>> update(@PathVariable Integer id,
                                                               @Valid @RequestBody ReservationDTO dto) {
        log.info("PUT /api/reservations/{}", id);
        ReservationDTO updated = reservationService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation updated successfully", updated));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<ReservationCancelResponse>> cancel(@PathVariable Integer id) {
        log.info("POST /api/reservations/{}/cancel", id);
        reservationService.cancel(id);
        ReservationCancelResponse response = new ReservationCancelResponse();
        response.setIdReservation(id);
        response.setStatus("CANCELLED");
        response.setRefundAmount(BigDecimal.ZERO);
        response.setMessage("Reservation cancelled successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation cancelled successfully", response));
    }

    @GetMapping("/{id}/tickets")
    public ResponseEntity<ApiResponse<List<TicketDTO>>> getReservationTickets(@PathVariable Integer id) {
        log.info("GET /api/reservations/{}/tickets", id);
        List<TicketDTO> tickets = correspondARepository.findByReservation_IdReservation(id)
                .stream()
                .map(c -> c.getTicket().getCodeTicket())
                .map(ticketService::getById)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation tickets fetched successfully", tickets));
    }
}
