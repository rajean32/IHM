package com.ihm.api;

import com.ihm.model.ApiResponse;
import com.ihm.model.dto.DashboardStatsDTO;
import com.ihm.model.dto.EventStatsDTO;
import com.ihm.model.dto.OrganizerDashboardDTO;
import com.ihm.schemat.ActionLog;
import com.ihm.service.ActionLogService;
import com.ihm.service.DashboardService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class DashboardController {

    private static final Logger log = LoggerFactory.getLogger(DashboardController.class);

    private final DashboardService dashboardService;
    private final ActionLogService actionLogService;

    public DashboardController(DashboardService dashboardService, ActionLogService actionLogService) {
        this.dashboardService = dashboardService;
        this.actionLogService = actionLogService;
    }

    @GetMapping("/admin/dashboard")
    public ResponseEntity<ApiResponse<DashboardStatsDTO>> getAdminDashboard() {
        log.info("GET /api/admin/dashboard");
        DashboardStatsDTO stats = dashboardService.getAdminStats();
        return ResponseEntity.ok(ApiResponse.success(200, "Admin dashboard stats fetched successfully", stats));
    }

    @GetMapping("/organisateurs/{code}/dashboard")
    public ResponseEntity<ApiResponse<OrganizerDashboardDTO>> getOrganizerDashboard(@PathVariable String code) {
        log.info("GET /api/organisateurs/{}/dashboard", code);
        OrganizerDashboardDTO stats = dashboardService.getOrganizerStats(code);
        return ResponseEntity.ok(ApiResponse.success(200, "Organizer dashboard stats fetched successfully", stats));
    }

    @GetMapping("/evenements/{id}/stats")
    public ResponseEntity<ApiResponse<EventStatsDTO>> getEventStats(@PathVariable Integer id) {
        log.info("GET /api/evenements/{}/stats", id);
        EventStatsDTO stats = dashboardService.getEventStats(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Event stats fetched successfully", stats));
    }

    @GetMapping("/admin/activity")
    public ResponseEntity<ApiResponse<List<ActionLog>>> getRecentActivity() {
        log.info("GET /api/admin/activity");
        List<ActionLog> logs = actionLogService.getRecentActions();
        return ResponseEntity.ok(ApiResponse.success(200, "Recent activity fetched successfully", logs));
    }
}
