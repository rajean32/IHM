package com.ihm.api;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.ApiResponse;
import com.ihm.model.dto.CorrespondADTO;
import com.ihm.repository.CorrespondARepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.repository.TicketRepository;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/correspond-a")
public class CorrespondAController {

    private static final Logger log = LoggerFactory.getLogger(CorrespondAController.class);

    private final CorrespondARepository correspondARepository;
    private final TicketRepository ticketRepository;
    private final ReservationRepository reservationRepository;

    public CorrespondAController(CorrespondARepository correspondARepository,
                                 TicketRepository ticketRepository,
                                 ReservationRepository reservationRepository) {
        this.correspondARepository = correspondARepository;
        this.ticketRepository = ticketRepository;
        this.reservationRepository = reservationRepository;
    }

    @GetMapping
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<CorrespondADTO>>> getAll() {
        log.info("GET /api/correspond-a");
        List<CorrespondADTO> data = correspondARepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mappings fetched successfully", data));
    }

    @GetMapping("/reservation/{idReservation}")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<CorrespondADTO>>> getByReservation(@PathVariable Integer idReservation) {
        log.info("GET /api/correspond-a/reservation/{}", idReservation);
        List<CorrespondADTO> data = correspondARepository.findByReservation_IdReservation(idReservation).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation ticket mappings fetched successfully", data));
    }

    @GetMapping("/ticket/{codeTicket}")
    @Transactional(readOnly = true)
    public ResponseEntity<ApiResponse<List<CorrespondADTO>>> getByTicket(@PathVariable String codeTicket) {
        log.info("GET /api/correspond-a/ticket/{}", codeTicket);
        List<CorrespondADTO> data = correspondARepository.findByTicket_CodeTicket(codeTicket).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket reservation mappings fetched successfully", data));
    }

    @PostMapping
    @Transactional
    public ResponseEntity<ApiResponse<CorrespondADTO>> create(@Valid @RequestBody CorrespondADTO dto) {
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
                .body(ApiResponse.success(201, "CorrespondA mapping created successfully", toDTO(saved)));
    }

    @DeleteMapping
    @Transactional
    public ResponseEntity<ApiResponse<Void>> delete(@RequestParam String codeTicket,
                                                      @RequestParam Integer idReservation) {
        log.info("DELETE /api/correspond-a - ticket: {}, reservation: {}", codeTicket, idReservation);
        CorrespondAId id = new CorrespondAId(codeTicket, idReservation);
        correspondARepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mapping deleted successfully"));
    }

    private CorrespondADTO toDTO(CorrespondA correspondA) {
        CorrespondADTO dto = new CorrespondADTO();
        dto.setCodeTicket(correspondA.getTicket().getCodeTicket());
        dto.setIdReservation(correspondA.getReservation().getIdReservation());
        return dto;
    }
}
