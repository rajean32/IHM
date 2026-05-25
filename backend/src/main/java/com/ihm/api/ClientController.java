package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ClientDTO;
import com.ihm.service.ClientService;
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

    public ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ClientDTO>>> getAll() {
        log.info("GET /api/clients");
        List<ClientDTO> data = clientService.getAll();
        return ResponseEntity.ok(ApiResponse.success(200, "Clients fetched successfully", data));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<ClientDTO>> getById(@PathVariable String code) {
        log.info("GET /api/clients/{}", code);
        ClientDTO data = clientService.getById(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client fetched successfully", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ClientDTO>> create(@Valid @RequestBody ClientDTO dto) {
        log.info("POST /api/clients - email: {}", dto.getEmail());
        ClientDTO data = clientService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Client created successfully", data));
    }

    @PutMapping("/{code}")
    public ResponseEntity<ApiResponse<ClientDTO>> update(@PathVariable String code,
                                                          @Valid @RequestBody ClientDTO dto) {
        log.info("PUT /api/clients/{}", code);
        ClientDTO data = clientService.update(code, dto);
        return ResponseEntity.ok(ApiResponse.success(200, "Client updated successfully", data));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String code) {
        log.info("DELETE /api/clients/{}", code);
        clientService.delete(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Client deleted successfully"));
    }
}
