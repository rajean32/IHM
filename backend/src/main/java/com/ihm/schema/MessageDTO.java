package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class MessageDTO {

    private Long idMessage;
    private Long idConversation;
    private String expediteur;
    private String destinataire;
    private String contenu;
    private LocalDateTime dateEnvoi;
    private boolean lu;

    public MessageDTO() {}

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
