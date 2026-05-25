package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ConcernerDTO;
import com.ihm.repository.ConcernerRepository;
import com.ihm.schemat.Concerner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/concerner")
public class ConcernerController {

    private static final Logger log = LoggerFactory.getLogger(ConcernerController.class);

    private final ConcernerRepository concernerRepository;

    public ConcernerController(ConcernerRepository concernerRepository) {
        this.concernerRepository = concernerRepository;
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
    public ResponseEntity<ApiResponse<ConcernerDTO>> create(@Valid @RequestBody ConcernerDTO dto) {
        log.info("POST /api/concerner - event: {}, ticket: {}, place: {}", dto.getIdEvenement(), dto.getCodeTicket(), dto.getNumeroPlace());
        Concerner concerner = new Concerner();
        com.ihm.schemat.ConcernerId id = new com.ihm.schemat.ConcernerId(dto.getIdEvenement(), dto.getCodeTicket(), dto.getNumeroPlace());
        concerner.setId(id);
        Concerner saved = concernerRepository.save(concerner);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Concerner mapping created successfully", toDTO(saved)));
    }

    @DeleteMapping
    public ResponseEntity<ApiResponse<Void>> delete(@RequestParam Integer idEvenement,
                                                     @RequestParam String codeTicket,
                                                     @RequestParam String numeroPlace) {
        log.info("DELETE /api/concerner - event: {}, ticket: {}, place: {}", idEvenement, codeTicket, numeroPlace);
        com.ihm.schemat.ConcernerId id = new com.ihm.schemat.ConcernerId(idEvenement, codeTicket, numeroPlace);
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
