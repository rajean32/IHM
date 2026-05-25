package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class TicketQRResponse {

    private String codeTicket;
    private String qrCodeBase64;
    private String evenementTitre;
    private String placeNumero;
    private String rang;
    private String typePlace;
    private String prix;
    private String status;

    public TicketQRResponse() {}

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

    public String getQrCodeBase64() { return qrCodeBase64; }
    public void setQrCodeBase64(String qrCodeBase64) { this.qrCodeBase64 = qrCodeBase64; }

    public String getEvenementTitre() { return evenementTitre; }
    public void setEvenementTitre(String evenementTitre) { this.evenementTitre = evenementTitre; }

    public String getPlaceNumero() { return placeNumero; }
    public void setPlaceNumero(String placeNumero) { this.placeNumero = placeNumero; }

    public String getRang() { return rang; }
    public void setRang(String rang) { this.rang = rang; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public String getPrix() { return prix; }
    public void setPrix(String prix) { this.prix = prix; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
