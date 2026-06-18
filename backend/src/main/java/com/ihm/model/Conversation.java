package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "CONVERSATION")
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idConversation")
    private Long idConversation;

    @Column(name = "participant1", length = 50, nullable = false)
    private String participant1;

    @Column(name = "participant2", length = 50, nullable = false)
    private String participant2;

    @Column(name = "dateCreation", nullable = false)
    private LocalDateTime dateCreation;

    @Column(name = "lastMessageAt")
    private LocalDateTime lastMessageAt;

    public Conversation() {}

    public Conversation(String participant1, String participant2) {
        this.participant1 = participant1;
        this.participant2 = participant2;
        this.dateCreation = LocalDateTime.now();
    }

    public Long getIdConversation() { return idConversation; }
    public void setIdConversation(Long idConversation) { this.idConversation = idConversation; }
    public String getParticipant1() { return participant1; }
    public void setParticipant1(String participant1) { this.participant1 = participant1; }
    public String getParticipant2() { return participant2; }
    public void setParticipant2(String participant2) { this.participant2 = participant2; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
    public LocalDateTime getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(LocalDateTime lastMessageAt) { this.lastMessageAt = lastMessageAt; }
}
