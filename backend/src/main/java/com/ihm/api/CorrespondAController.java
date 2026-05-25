package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.repository.CorrespondARepository;
import com.ihm.schemat.CorrespondA;
import com.ihm.schemat.CorrespondAId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/correspond-a")
public class CorrespondAController {

    private static final Logger log = LoggerFactory.getLogger(CorrespondAController.class);

    private final CorrespondARepository correspondARepository;

    public CorrespondAController(CorrespondARepository correspondARepository) {
        this.correspondARepository = correspondARepository;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAll() {
        log.info("GET /api/correspond-a");
        List<Map<String, Object>> data = correspondARepository.findAll().stream()
                .map(this::toMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mappings fetched successfully", data));
    }

    @GetMapping("/reservation/{idReservation}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getByReservation(@PathVariable Integer idReservation) {
        log.info("GET /api/correspond-a/reservation/{}", idReservation);
        List<Map<String, Object>> data = correspondARepository.findByReservation_IdReservation(idReservation).stream()
                .map(this::toMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation ticket mappings fetched successfully", data));
    }

    @GetMapping("/ticket/{codeTicket}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getByTicket(@PathVariable String codeTicket) {
        log.info("GET /api/correspond-a/ticket/{}", codeTicket);
        List<Map<String, Object>> data = correspondARepository.findByTicket_CodeTicket(codeTicket).stream()
                .map(this::toMap)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(200, "Ticket reservation mappings fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> create(@Valid @RequestBody Map<String, String> dto) {
        log.info("POST /api/correspond-a - ticket: {}, reservation: {}", dto.get("codeTicket"), dto.get("idReservation"));
        CorrespondAId id = new CorrespondAId(dto.get("codeTicket"), Integer.parseInt(dto.get("idReservation")));
        CorrespondA correspondA = new CorrespondA();
        correspondA.setId(id);
        CorrespondA saved = correspondARepository.save(correspondA);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "CorrespondA mapping created successfully", toMap(saved)));
    }

    @DeleteMapping
    public ResponseEntity<ApiResponse<Void>> delete(@RequestParam String codeTicket,
                                                     @RequestParam Integer idReservation) {
        log.info("DELETE /api/correspond-a - ticket: {}, reservation: {}", codeTicket, idReservation);
        CorrespondAId id = new CorrespondAId(codeTicket, idReservation);
        correspondARepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "CorrespondA mapping deleted successfully"));
    }

    private Map<String, Object> toMap(CorrespondA correspondA) {
        Map<String, Object> map = new HashMap<>();
        map.put("codeTicket", correspondA.getTicket().getCodeTicket());
        map.put("idReservation", correspondA.getReservation().getIdReservation());
        return map;
    }
}
