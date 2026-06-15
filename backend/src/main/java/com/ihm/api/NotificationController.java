package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.NotificationDTO;
import com.ihm.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private static final Logger log = LoggerFactory.getLogger(NotificationController.class);

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getUserNotifications(
            @RequestParam String userId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Boolean isRead,
            @RequestParam(required = false) LocalDateTime dateFrom,
            @RequestParam(required = false) LocalDateTime dateTo) {
        log.debug("Fetching notifications for user: {} (type={}, isRead={})", userId, type, isRead);
        List<NotificationDTO> notifications;
        if (type != null || isRead != null || dateFrom != null || dateTo != null) {
            notifications = notificationService.getFilteredNotifications(userId, type, isRead, dateFrom, dateTo);
        } else {
            notifications = notificationService.getUserNotifications(userId);
        }
        return ResponseEntity.ok(ApiResponse.success(200, "Notifications retrieved", notifications));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(
            @RequestParam String userId) {
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(ApiResponse.success(200, "Unread count retrieved", count));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Notification marked as read"));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
            @RequestBody NotificationDTO.MarkAllReadRequest request) {
        notificationService.markAllAsRead(request.getUserId());
        return ResponseEntity.ok(ApiResponse.success(200, "All notifications marked as read"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        notificationService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Notification deleted"));
    }

    @DeleteMapping
    public ResponseEntity<ApiResponse<Void>> deleteAll(@RequestParam String userId) {
        notificationService.deleteAll(userId);
        return ResponseEntity.ok(ApiResponse.success(200, "All notifications deleted"));
    }
}
