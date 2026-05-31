package com.ihm.api;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ConcernerDTO;
import com.ihm.repository.ConcernerRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.PlaceRepository;
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
@RequestMapping("/api/concerner")
public class ConcernerController {

    private static final Logger log = LoggerFactory.getLogger(ConcernerController.class);

    private final ConcernerRepository concernerRepository;
    private final EvenementRepository evenementRepository;
    private final TicketRepository ticketRepository;
    private final PlaceRepository placeRepository;

    public ConcernerController(ConcernerRepository concernerRepository,
                               EvenementRepository evenementRepository,
                               TicketRepository ticketRepository,
                               PlaceRepository placeRepository) {
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.ticketRepository = ticketRepository;
        this.placeRepository = placeRepository;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ConcernerDTO>>> getAll() {
        log.info("GET /api/concerner");
        List<ConcernerDTO> data = concernerRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Concerner mappings fetched successfully", data));
    }

    @GetMapping("/evenement/{idEvent}")
    public ResponseEntity<ApiResponse<List<ConcernerDTO>>> getByEvent(@PathVariable Integer idEvent) {
        log.info("GET /api/concerner/evenement/{}", idEvent);
        List<ConcernerDTO> data = concernerRepository.findByEvenement_IdEvenement(idEvent).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Event ticket mappings fetched successfully", data));
    }

    @GetMapping("/ticket/{codeTicket}")
    public ResponseEntity<ApiResponse<List<ConcernerDTO>>> getByTicket(@PathVariable String codeTicket) {
        log.info("GET /api/concerner/ticket/{}", codeTicket);
        List<ConcernerDTO> data = concernerRepository.findByTicket_CodeTicket(codeTicket).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket event mappings fetched successfully", data));
    }

    @GetMapping("/place/{numeroPlace}")
    public ResponseEntity<ApiResponse<List<ConcernerDTO>>> getByPlace(@PathVariable String numeroPlace) {
        log.info("GET /api/concerner/place/{}", numeroPlace);
        List<ConcernerDTO> data = concernerRepository.findByPlace_NumeroPlace(numeroPlace).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Place ticket mappings fetched successfully", data));
    }

    @PostMapping
    @Transactional
    public ResponseEntity<ApiResponse<ConcernerDTO>> create(@Valid @RequestBody ConcernerDTO dto) {
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

        place.setStatut(StatutPlace.RESERVEE);
        placeRepository.save(place);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Concerner mapping created successfully", toDTO(saved)));
    }

    @DeleteMapping
    @Transactional
    public ResponseEntity<ApiResponse<Void>> delete(@RequestParam Integer idEvenement,
                                                      @RequestParam String codeTicket,
                                                      @RequestParam String numeroPlace) {
        log.info("DELETE /api/concerner - event: {}, ticket: {}, place: {}", idEvenement, codeTicket, numeroPlace);
        ConcernerId id = new ConcernerId(idEvenement, codeTicket, numeroPlace);

        Place place = placeRepository.findByNumeroPlace(numeroPlace)
                .orElse(null);
        if (place != null) {
            place.setStatut(StatutPlace.DISPONIBLE);
            placeRepository.save(place);
        }

        concernerRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Concerner mapping deleted successfully"));
    }

    private ConcernerDTO toDTO(Concerner concerner) {
        ConcernerDTO dto = new ConcernerDTO();
        dto.setIdEvenement(concerner.getEvenement().getIdEvenement());
        dto.setCodeTicket(concerner.getTicket().getCodeTicket());
        dto.setNumeroPlace(concerner.getPlace().getNumeroPlace());
        return dto;
    }
}
