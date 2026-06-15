package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "IN_APP_NOTIFICATIONS")
public class InAppNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;

    @Column(name = "user_id", length = 255, nullable = false)
    private String userId;

    @Column(name = "title", length = 100, nullable = false)
    private String title;

    @Column(name = "message", length = 500, nullable = false)
    private String message;

    @Column(name = "type", length = 50, nullable = false)
    private String type;

    @Column(name = "is_read", nullable = false)
    private boolean isRead = false;

    @Column(name = "id_cible", length = 255)
    private String idCible;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public InAppNotification() {}

    public InAppNotification(String userId, String title, String message, String type, String idCible) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.idCible = idCible;
        this.isRead = false;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }
    public String getIdCible() { return idCible; }
    public void setIdCible(String idCible) { this.idCible = idCible; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
