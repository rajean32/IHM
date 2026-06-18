package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "MESSAGE")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idMessage")
    private Long idMessage;

    @Column(name = "idConversation", nullable = false)
    private Long idConversation;

    @Column(name = "expediteur", length = 50, nullable = false)
    private String expediteur;

    @Column(name = "destinataire", length = 50, nullable = false)
    private String destinataire;

    @Column(name = "contenu", columnDefinition = "TEXT", nullable = false)
    private String contenu;

    @Column(name = "dateEnvoi", nullable = false)
    private LocalDateTime dateEnvoi;

    @Column(name = "lu", nullable = false)
    private boolean lu = false;

    public Message() {}

    public Message(Long idConversation, String expediteur, String destinataire, String contenu) {
        this.idConversation = idConversation;
        this.expediteur = expediteur;
        this.destinataire = destinataire;
        this.contenu = contenu;
        this.dateEnvoi = LocalDateTime.now();
        this.lu = false;
    }

    public Long getIdMessage() { return idMessage; }
    public void setIdMessage(Long idMessage) { this.idMessage = idMessage; }
    public Long getIdConversation() { return idConversation; }
    public void setIdConversation(Long idConversation) { this.idConversation = idConversation; }
    public String getExpediteur() { return expediteur; }
    public void setExpediteur(String expediteur) { this.expediteur = expediteur; }
    public String getDestinataire() { return destinataire; }
    public void setDestinataire(String destinataire) { this.destinataire = destinataire; }
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    public LocalDateTime getDateEnvoi() { return dateEnvoi; }
    public void setDateEnvoi(LocalDateTime dateEnvoi) { this.dateEnvoi = dateEnvoi; }
    public boolean isLu() { return lu; }
    public void setLu(boolean lu) { this.lu = lu; }
}
