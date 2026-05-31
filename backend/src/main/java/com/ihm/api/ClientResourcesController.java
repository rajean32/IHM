package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ClientTicketDTO;
import com.ihm.model.dto.PaiementDTO;
import com.ihm.model.dto.ReservationDTO;
import com.ihm.model.dto.TicketDTO;
import com.ihm.service.ClientService;
import com.ihm.service.PaiementService;
import com.ihm.service.ReservationService;
import com.ihm.service.TicketService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/clients")
public class ClientResourcesController {

    private static final Logger log = LoggerFactory.getLogger(ClientResourcesController.class);

    private final ReservationService reservationService;
    private final TicketService ticketService;
    private final PaiementService paiementService;
    private final ClientService clientService;

    public ClientResourcesController(ReservationService reservationService,
                                     TicketService ticketService,
                                     PaiementService paiementService,
                                     ClientService clientService) {
        this.reservationService = reservationService;
        this.ticketService = ticketService;
        this.paiementService = paiementService;
        this.clientService = clientService;
    }

    @GetMapping("/{code}/reservations")
    public ResponseEntity<ApiResponse<List<ReservationDTO>>> getClientReservations(@PathVariable String code) {
        log.info("GET /api/clients/{}/reservations", code);
        List<ReservationDTO> reservations = reservationService.getByClient(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client reservations fetched successfully", reservations));
    }

    @GetMapping("/{code}/tickets")
    public ResponseEntity<ApiResponse<List<ClientTicketDTO>>> getClientTickets(@PathVariable String code) {
        log.info("GET /api/clients/{}/tickets", code);
        List<ClientTicketDTO> tickets = clientService.getClientTickets(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client tickets fetched successfully", tickets));
    }

    @GetMapping("/{code}/payments")
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getClientPayments(@PathVariable String code) {
        log.info("GET /api/clients/{}/payments", code);
        List<PaiementDTO> allPayments = paiementService.getByClient(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client payments fetched successfully", allPayments));
    }
}
