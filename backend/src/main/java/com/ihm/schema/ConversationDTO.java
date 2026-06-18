package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ConversationDTO {

    private Long idConversation;
    private String participant1;
    private String participant2;
    private String participant1Nom;
    private String participant2Nom;
    private LocalDateTime dateCreation;
    private LocalDateTime lastMessageAt;
    private MessageDTO lastMessage;
    private long nonLu;

    public ConversationDTO() {}

    public Long getIdConversation() { return idConversation; }
    public void setIdConversation(Long idConversation) { this.idConversation = idConversation; }
    public String getParticipant1() { return participant1; }
    public void setParticipant1(String participant1) { this.participant1 = participant1; }
    public String getParticipant2() { return participant2; }
    public void setParticipant2(String participant2) { this.participant2 = participant2; }
    public String getParticipant1Nom() { return participant1Nom; }
    public void setParticipant1Nom(String participant1Nom) { this.participant1Nom = participant1Nom; }
    public String getParticipant2Nom() { return participant2Nom; }
    public void setParticipant2Nom(String participant2Nom) { this.participant2Nom = participant2Nom; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
    public LocalDateTime getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(LocalDateTime lastMessageAt) { this.lastMessageAt = lastMessageAt; }
    public MessageDTO getLastMessage() { return lastMessage; }
    public void setLastMessage(MessageDTO lastMessage) { this.lastMessage = lastMessage; }
    public long getNonLu() { return nonLu; }
    public void setNonLu(long nonLu) { this.nonLu = nonLu; }
}
