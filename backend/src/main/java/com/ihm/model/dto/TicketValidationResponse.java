package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class TicketValidationResponse {

    private boolean valid;
    private String codeTicket;
    private String evenementTitre;
    private String placeNumero;
    private String clientNom;
    private String message;

    public TicketValidationResponse() {}

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

    public String getEvenementTitre() { return evenementTitre; }
    public void setEvenementTitre(String evenementTitre) { this.evenementTitre = evenementTitre; }

    public String getPlaceNumero() { return placeNumero; }
    public void setPlaceNumero(String placeNumero) { this.placeNumero = placeNumero; }

    public String getClientNom() { return clientNom; }
    public void setClientNom(String clientNom) { this.clientNom = clientNom; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
