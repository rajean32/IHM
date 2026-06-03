package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.ClientDTO;
import com.ihm.schema.PaiementDTO;
import com.ihm.schema.ReservationDTO;
import com.ihm.service.ClientService;
import com.ihm.service.PaiementService;
import com.ihm.service.ReservationService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

    private static final Logger log = LoggerFactory.getLogger(ClientController.class);

    private final ClientService clientService;
    private final ReservationService reservationService;
    private final PaiementService paiementService;

    public ClientController(ClientService clientService,
                            ReservationService reservationService,
                            PaiementService paiementService) {
        this.clientService = clientService;
        this.reservationService = reservationService;
        this.paiementService = paiementService;
    }
   // all client 
    @GetMapping
    public ResponseEntity<ApiResponse<List<ClientDTO>>> getAll() {
        log.info("GET /api/clients");
        List<ClientDTO> data = clientService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Clients fetched successfully", data));
    }
    // get all client by id
    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<ClientDTO>> getById(@PathVariable String code) {
        log.info("GET /api/clients/{}", code);
        ClientDTO data = clientService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client fetched successfully", data));
    }
    // creation de compte client
    @PostMapping
    public ResponseEntity<ApiResponse<ClientDTO>> create(@Valid @RequestBody ClientDTO dto) {
        log.info("POST /api/clients - email: {}", dto.getEmail());
        ClientDTO data = clientService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Client created successfully", data));
    }
    // modification
    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<ClientDTO>> update(@PathVariable String code,
                                                          @Valid @RequestBody ClientDTO dto) {
        log.info("PUT /api/clients/{}", code);
        ClientDTO data = clientService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Client updated successfully", data));
    }
    // suppression
    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/clients/{}", code);
        clientService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client deleted successfully"));
    }
    // reservations du client
    @GetMapping("/{code}/reservations")
    public ResponseEntity<ApiResponse<List<ReservationDTO>>> getClientReservations(@PathVariable String code) {
        log.info("GET /api/clients/{}/reservations", code);
        List<ReservationDTO> reservations = reservationService.getByClient(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client reservations fetched successfully", reservations));
    }
    // tokets du client
    @GetMapping("/{code}/tickets")
    public ResponseEntity<ApiResponse<List<ClientDTO.ClientTicket>>> getClientTickets(@PathVariable String code) {
        log.info("GET /api/clients/{}/tickets", code);
        List<ClientDTO.ClientTicket> tickets = clientService.getClientTickets(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client tickets fetched successfully", tickets));
    }
    // paiement du clients
    @GetMapping("/{code}/payments")
    public ResponseEntity<ApiResponse<List<PaiementDTO>>> getClientPayments(@PathVariable String code) {
        log.info("GET /api/clients/{}/payments", code);
        List<PaiementDTO> allPayments = paiementService.getByClient(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client payments fetched successfully", allPayments));
    }
}
