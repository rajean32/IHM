package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.ConsistencyReportDTO;
import com.ihm.service.DataConsistencyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/consistency")
@PreAuthorize("hasRole('ADMINISTRATEUR')")
public class ConsistencyController {

    private static final Logger log = LoggerFactory.getLogger(ConsistencyController.class);

    private final DataConsistencyService dataConsistencyService;

    public ConsistencyController(DataConsistencyService dataConsistencyService) {
        this.dataConsistencyService = dataConsistencyService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<ConsistencyReportDTO>> checkConsistency() {
        log.info("GET /api/admin/consistency");
        ConsistencyReportDTO report = dataConsistencyService.generateReport();
        return ResponseEntity.ok(ApiResponse.success(200, "Consistency check completed", report));
    }
}
