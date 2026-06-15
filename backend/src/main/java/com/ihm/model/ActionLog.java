package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
@Entity
@Table(name = "ACTION_LOG")
public class ActionLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "IdAction")
    private Long idAction;
    @Column(name = "CodeUtilisateur", length = 50, nullable = false)
    private String codeUtilisateur;
    @Column(name = "Action", length = 255, nullable = false)
    private String action;
    @Column(name = "EntityType", length = 100)
    private String entityType;
    @Column(name = "EntityId", length = 100)
    private String entityId;
    @Column(name = "Details", columnDefinition = "TEXT")
    private String details;
    @Column(name = "DateAction", nullable = false)
    private LocalDateTime dateAction;

    @Column(name = "Reverted")
    private boolean reverted = false;

    public ActionLog() {}
    public ActionLog(String codeUtilisateur, String action, String entityType, String entityId, String details) {
        this.codeUtilisateur = codeUtilisateur;
        this.action = action;
        this.entityType = entityType;
        this.entityId = entityId;
        this.details = details;
        this.dateAction = LocalDateTime.now();
    }
    public Long getIdAction() { return idAction; }
    public void setIdAction(Long idAction) { this.idAction = idAction; }
    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getEntityId() { return entityId; }
    public void setEntityId(String entityId) { this.entityId = entityId; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
    public LocalDateTime getDateAction() { return dateAction; }
    public void setDateAction(LocalDateTime dateAction) { this.dateAction = dateAction; }

    public boolean isReverted() { return reverted; }
    public void setReverted(boolean reverted) { this.reverted = reverted; }
}
