package com.ihm.api;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.ApiResponse;
import com.ihm.schema.ReservationDTO;
import com.ihm.schema.TicketDTO;
import com.ihm.repository.CorrespondARepository;
import com.ihm.repository.ConcernerRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.repository.TicketRepository;
import com.ihm.model.*;
import com.ihm.service.ReservationService;
import com.ihm.service.TicketService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class ReservationController {

    private static final Logger log = LoggerFactory.getLogger(ReservationController.class);

    private final ReservationService reservationService;
    private final TicketService ticketService;
    private final CorrespondARepository correspondARepository;
    private final ConcernerRepository concernerRepository;
    private final EvenementRepository evenementRepository;
    private final TicketRepository ticketRepository;
    private final PlaceRepository placeRepository;
    private final ReservationRepository reservationRepository;
    private final EvenementPlaceConfigurationRepository configRepository;

    public ReservationController(ReservationService reservationService,
                                  TicketService ticketService,
                                  CorrespondARepository correspondARepository,
                                  ConcernerRepository concernerRepository,
                                  EvenementRepository evenementRepository,
                                  TicketRepository ticketRepository,
                                  PlaceRepository placeRepository,
                                  ReservationRepository reservationRepository,
                                  EvenementPlaceConfigurationRepository configRepository) {
        this.reservationService = reservationService;
        this.ticketService = ticketService;
        this.correspondARepository = correspondARepository;
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.ticketRepository = ticketRepository;
        this.placeRepository = placeRepository;
        this.reservationRepository = reservationRepository;
        this.configRepository = configRepository;
    }

    // liste des réservations
    @GetMapping("/reservations")
    public ResponseEntity<ApiResponse<List<ReservationDTO>>> getAll(
            @RequestParam(required = false) String client) {
        log.info("GET /api/reservations");
        List<ReservationDTO> data;
        if (client != null) {
            data = reservationService.getByClient(client);
        } else {
            data = reservationService.getAll();
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Reservations fetched successfully", data));
    }

    // détail d'une réservation
    @GetMapping("/reservations/{id}")
    public ResponseEntity<ApiResponse<ReservationDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/reservations/{}", id);
        ReservationDTO data = reservationService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation fetched successfully", data));
    }

    // création d'une réservation
    @PostMapping("/reservations")
    public ResponseEntity<ApiResponse<ReservationDTO>> create(@Valid @RequestBody ReservationDTO dto) {
        log.info("POST /api/reservations - client: {}", dto.getCodeClient());
        ReservationDTO data = reservationService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Reservation created successfully", data));
    }

    // modification d'une réservation
    @PutMapping("/reservations/{id}")
    public ResponseEntity<ApiResponse<ReservationDTO>> update(@PathVariable Integer id,
                                                               @Valid @RequestBody ReservationDTO dto) {
        log.info("PUT /api/reservations/{}", id);
        ReservationDTO updated = reservationService.update(id, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation updated successfully", updated));
    }

    // suppression d'une réservation
    @DeleteMapping("/reservations/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/reservations/{}", id);
        reservationService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation deleted successfully"));
    }

    // annulation d'une réservation
    @PostMapping("/reservations/{id}/cancel")
    public ResponseEntity<ApiResponse<ReservationDTO.CancelResponse>> cancel(@PathVariable Integer id) {
        log.info("POST /api/reservations/{}/cancel", id);
        reservationService.cancel(id);
        ReservationDTO.CancelResponse response = new ReservationDTO.CancelResponse();
        response.setIdReservation(id);
        response.setStatus("CANCELLED");
        response.setRefundAmount(BigDecimal.ZERO);
        response.setMessage("Reservation cancelled successfully");
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation cancelled successfully", response));
    }

    // tickets d'une réservation
    @GetMapping("/reservations/{id}/tickets")
    public ResponseEntity<ApiResponse<List<TicketDTO>>> getReservationTickets(@PathVariable Integer id) {
        log.info("GET /api/reservations/{}/tickets", id);
        List<TicketDTO> tickets = correspondARepository.findByReservation_IdReservation(id)
                .stream()
                .map(c -> c.getTicket().getCodeTicket())
                .map(ticketService::getById)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation tickets fetched successfully", tickets));
    }

    // achat de billets
    @PostMapping("/achat")
    public ResponseEntity<ApiResponse<Map<String, Object>>> purchase(@RequestBody ReservationDTO.PurchaseRequest request) {
        int ticketCount = request.getTickets() != null ? request.getTickets().size() : 0;
        log.info("POST /api/achat - client: {}, {} tickets, montant: {}",
                request.getCodeClient(), ticketCount, request.getMontant());
        Map<String, Object> result = reservationService.processPurchase(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Purchase completed successfully", result));
    }

    // liste des mappings concerner
    @GetMapping("/concerner")
    public ResponseEntity<ApiResponse<List<TicketDTO.Concerner>>> getAllConcerner() {
        log.info("GET /api/concerner");
        List<TicketDTO.Concerner> data = concernerRepository.findAll().stream()
                .map(this::toConcernerDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Concerner mappings fetched successfully", data));
    }

    // concerner par événement
    @GetMapping("/concerner/evenement/{idEvent}")
    public ResponseEntity<ApiResponse<List<TicketDTO.Concerner>>> getConcernerByEvent(@PathVariable Integer idEvent) {
        log.info("GET /api/concerner/evenement/{}", idEvent);
        List<TicketDTO.Concerner> data = concernerRepository.findByEvenement_IdEvenement(idEvent).stream()
                .map(this::toConcernerDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Event ticket mappings fetched successfully", data));
    }

    // concerner par ticket
    @GetMapping("/concerner/ticket/{codeTicket}")
    public ResponseEntity<ApiResponse<List<TicketDTO.Concerner>>> getConcernerByTicket(@PathVariable String codeTicket) {
        log.info("GET /api/concerner/ticket/{}", codeTicket);
        List<TicketDTO.Concerner> data = concernerRepository.findByTicket_CodeTicket(codeTicket).stream()
                .map(this::toConcernerDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket event mappings fetched successfully", data));
    }

    // concerner par place
    @GetMapping("/concerner/place/{numeroPlace}")
    public ResponseEntity<ApiResponse<List<TicketDTO.Concerner>>> getConcernerByPlace(@PathVariable String numeroPlace) {
        log.info("GET /api/concerner/place/{}", numeroPlace);
        List<TicketDTO.Concerner> data = concernerRepository.findByPlace_NumeroPlace(numeroPlace).stream()
                .map(this::toConcernerDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Place ticket mappings fetched successfully", data));
    }

    // création d'un mapping concerner
    @PostMapping("/concerner")
    @Transactional
    public ResponseEntity<ApiResponse<TicketDTO.Concerner>> createConcerner(@Valid @RequestBody TicketDTO.Concerner dto) {
        log.info("POST /api/concerner - event: {}, ticket: {}, place: {}", dto.getIdEvenement(), dto.getCodeTicket(), dto.getNumeroPlace());
        Evenement event = evenementRepository.findByIdEvenement(dto.getIdEvenement())
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", dto.getIdEvenement()));
        Ticket ticket = ticketRepository.findByCodeTicket(dto.getCodeTicket())
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", dto.getCodeTicket()));
        Place place = placeRepository.findByNumeroPlace(dto.getNumeroPlace())
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", dto.getNumeroPlace()));

        Concerner concerner = new Concerner();
        ConcernerId id = new ConcernerId(dto.getIdEvenement(), dto.getCodeTicket(), dto.getNumeroPlace());
        concerner.setId(id);
        concerner.setEvenement(event);
        concerner.setTicket(ticket);
        concerner.setPlace(place);
        Concerner saved = concernerRepository.save(concerner);

        EvenementPlaceConfiguration config = configRepository
                .findByEvenement_IdEvenementAndPlace_NumeroPlace(dto.getIdEvenement(), dto.getNumeroPlace())
                .orElse(null);
        if (config != null) {
            config.setStatut("RESERVEE");
            configRepository.save(config);
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Concerner mapping created successfully", toConcernerDTO(saved)));
    }

    // suppression d'un mapping concerner
    @DeleteMapping("/concerner")
    @Transactional
    public ResponseEntity<ApiResponse<Void>> deleteConcerner(@RequestParam Integer idEvenement,
                                                               @RequestParam String codeTicket,
                                                               @RequestParam String numeroPlace) {
        log.info("DELETE /api/concerner - event: {}, ticket: {}, place: {}", idEvenement, codeTicket, numeroPlace);
        ConcernerId id = new ConcernerId(idEvenement, codeTicket, numeroPlace);

        EvenementPlaceConfiguration config = configRepository
                .findByEvenement_IdEvenementAndPlace_NumeroPlace(idEvenement, numeroPlace)
                .orElse(null);
        if (config != null) {
            config.setStatut("DISPONIBLE");
            configRepository.save(config);
        }

        concernerRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Concerner mapping deleted successfully"));
    }

    // liste des correspondances ticket-réservation
    @GetMapping("/correspond-a")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<ReservationDTO.CorrespondA>>> getAllCorrespondA() {
        log.info("GET /api/correspond-a");
        List<ReservationDTO.CorrespondA> data = correspondARepository.findAll().stream()
                .map(this::toCorrespondADTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mappings fetched successfully", data));
    }

    // correspondances par réservation
    @GetMapping("/correspond-a/reservation/{idReservation}")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<ReservationDTO.CorrespondA>>> getCorrespondAByReservation(@PathVariable Integer idReservation) {
        log.info("GET /api/correspond-a/reservation/{}", idReservation);
        List<ReservationDTO.CorrespondA> data = correspondARepository.findByReservation_IdReservation(idReservation).stream()
                .map(this::toCorrespondADTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation ticket mappings fetched successfully", data));
    }

    // correspondances par ticket
    @GetMapping("/correspond-a/ticket/{codeTicket}")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<ReservationDTO.CorrespondA>>> getCorrespondAByTicket(@PathVariable String codeTicket) {
        log.info("GET /api/correspond-a/ticket/{}", codeTicket);
        List<ReservationDTO.CorrespondA> data = correspondARepository.findByTicket_CodeTicket(codeTicket).stream()
                .map(this::toCorrespondADTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket reservation mappings fetched successfully", data));
    }

    // création d'une correspondance ticket-réservation
    @PostMapping("/correspond-a")
    @Transactional
    public ResponseEntity<ApiResponse<ReservationDTO.CorrespondA>> createCorrespondA(@Valid @RequestBody ReservationDTO.CorrespondA dto) {
        log.info("POST /api/correspond-a - ticket: {}, reservation: {}", dto.getCodeTicket(), dto.getIdReservation());
        Ticket ticket = ticketRepository.findByCodeTicket(dto.getCodeTicket())
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", dto.getCodeTicket()));
        Reservation reservation = reservationRepository.findByIdReservation(dto.getIdReservation())
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", dto.getIdReservation()));

        CorrespondAId id = new CorrespondAId(dto.getCodeTicket(), dto.getIdReservation());
        CorrespondA correspondA = new CorrespondA();
        correspondA.setId(id);
        correspondA.setTicket(ticket);
        correspondA.setReservation(reservation);
        CorrespondA saved = correspondARepository.save(correspondA);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "CorrespondA mapping created successfully", toCorrespondADTO(saved)));
    }

    // suppression d'une correspondance ticket-réservation
    @DeleteMapping("/correspond-a")
    @Transactional
    public ResponseEntity<ApiResponse<Void>> deleteCorrespondA(@RequestParam String codeTicket,
                                                                 @RequestParam Integer idReservation) {
        log.info("DELETE /api/correspond-a - ticket: {}, reservation: {}", codeTicket, idReservation);
        CorrespondAId id = new CorrespondAId(codeTicket, idReservation);
        correspondARepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mapping deleted successfully"));
    }

    private TicketDTO.Concerner toConcernerDTO(Concerner concerner) {
        TicketDTO.Concerner dto = new TicketDTO.Concerner();
        dto.setIdEvenement(concerner.getEvenement().getIdEvenement());
        dto.setCodeTicket(concerner.getTicket().getCodeTicket());
        dto.setNumeroPlace(concerner.getPlace().getNumeroPlace());
        return dto;
    }

    private ReservationDTO.CorrespondA toCorrespondADTO(CorrespondA correspondA) {
        ReservationDTO.CorrespondA dto = new ReservationDTO.CorrespondA();
        dto.setCodeTicket(correspondA.getTicket().getCodeTicket());
        dto.setIdReservation(correspondA.getReservation().getIdReservation());
        return dto;
    }
}
