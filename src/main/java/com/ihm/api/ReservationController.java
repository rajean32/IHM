package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ReservationDTO;
import com.ihm.service.ReservationService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    private static final Logger log = LoggerFactory.getLogger(ReservationController.class);

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @GetMapping
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

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ReservationDTO>> getById(@PathVariable Integer id) {
        log.info("GET /api/reservations/{}", id);
        ReservationDTO data = reservationService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ReservationDTO>> create(@Valid @RequestBody ReservationDTO dto) {
        log.info("POST /api/reservations - client: {}", dto.getCodeClient());
        ReservationDTO data = reservationService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Reservation created successfully", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        log.info("DELETE /api/reservations/{}", id);
        reservationService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Reservation deleted successfully"));
    }
}
