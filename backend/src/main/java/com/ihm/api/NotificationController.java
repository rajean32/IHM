package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.NotificationDTO;
import com.ihm.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

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
        List<NotificationDTO> all = notificationService.getUserNotifications(userId);

        Stream<NotificationDTO> stream = all.stream();
        if (type != null) stream = stream.filter(n -> type.equals(n.getType()));
        if (isRead != null) stream = stream.filter(n -> isRead == n.isRead());
        if (dateFrom != null) stream = stream.filter(n -> !n.getCreatedAt().isBefore(dateFrom));
        if (dateTo != null) stream = stream.filter(n -> !n.getCreatedAt().isAfter(dateTo));

        return ResponseEntity.ok(ApiResponse.success(200, "Notifications retrieved", stream.collect(Collectors.toList())));
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
