package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.InAppNotification;
import com.ihm.repository.InAppNotificationRepository;
import com.ihm.schema.NotificationDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final InAppNotificationRepository repository;
    private final SimpMessagingTemplate messagingTemplate;

    public NotificationService(InAppNotificationRepository repository,
                               SimpMessagingTemplate messagingTemplate) {
        this.repository = repository;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public NotificationDTO create(String userId, String title, String message, String type, String idCible) {
        InAppNotification entity = new InAppNotification(userId, title, message, type, idCible);
        InAppNotification saved = repository.save(entity);
        NotificationDTO dto = toDTO(saved);

        try {
            messagingTemplate.convertAndSendToUser(userId, "/queue/notifications", dto);
        } catch (Exception e) {
            log.warn("WebSocket push failed for user {}: {}", userId, e.getMessage());
        }

        log.debug("Notification created for user {}: {}", userId, title);
        return dto;
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getUserNotifications(String userId) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NotificationDTO> getFilteredNotifications(String userId, String type, Boolean isRead,
                                                           LocalDateTime dateFrom, LocalDateTime dateTo) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .filter(n -> type == null || type.equals(n.getType()))
                .filter(n -> isRead == null || isRead == n.isRead())
                .filter(n -> dateFrom == null || !n.getCreatedAt().isBefore(dateFrom))
                .filter(n -> dateTo == null || !n.getCreatedAt().isAfter(dateTo))
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(String userId) {
        return repository.countByUserIdAndReadFalse(userId);
    }

    @Transactional
    public void markAsRead(Long id) {
        InAppNotification entity = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("InAppNotification", "id", id));
        entity.setRead(true);
        repository.save(entity);
        log.debug("Notification {} marked as read", id);
    }

    @Transactional
    public void markAllAsRead(String userId) {
        List<InAppNotification> unread = repository.findByUserIdAndReadFalseOrderByCreatedAtDesc(userId);
        for (InAppNotification n : unread) {
            n.setRead(true);
        }
        repository.saveAll(unread);
        log.debug("All notifications marked as read for user {}", userId);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("InAppNotification", "id", id);
        }
        repository.deleteById(id);
        log.debug("Notification {} deleted", id);
    }

    @Transactional
    public void deleteAll(String userId) {
        List<InAppNotification> notifications = repository.findByUserIdOrderByCreatedAtDesc(userId);
        repository.deleteAll(notifications);
        log.debug("All notifications deleted for user {}", userId);
    }

    private NotificationDTO toDTO(InAppNotification entity) {
        NotificationDTO dto = new NotificationDTO();
        dto.setId(entity.getId());
        dto.setUserId(entity.getUserId());
        dto.setTitle(entity.getTitle());
        dto.setMessage(entity.getMessage());
        dto.setType(entity.getType());
        dto.setRead(entity.isRead());
        dto.setIdCible(entity.getIdCible());
        dto.setCreatedAt(entity.getCreatedAt());
        return dto;
    }
}
