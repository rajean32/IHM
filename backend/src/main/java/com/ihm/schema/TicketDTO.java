package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class TicketDTO {

    @NotBlank(message = "Ticket code is required")
    private String codeTicket;
    @DecimalMin(value = "0.0", inclusive = true, message = "Price must be positive")
    private BigDecimal prix;
    private String numeroPlace;
    private Integer idEvenement;
    private String evenementTitre;
    private String dateEvenement;
    private String heureEvenement;
    private String lieuNom;
    private String salleNom;
    private String rang;
    private String typePlace;
    private String statut;
    private Integer idZone;
    private String zoneNom;

    public TicketDTO() {}

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getEvenementTitre() { return evenementTitre; }
    public void setEvenementTitre(String evenementTitre) { this.evenementTitre = evenementTitre; }
    public String getDateEvenement() { return dateEvenement; }
    public void setDateEvenement(String dateEvenement) { this.dateEvenement = dateEvenement; }
    public String getHeureEvenement() { return heureEvenement; }
    public void setHeureEvenement(String heureEvenement) { this.heureEvenement = heureEvenement; }
    public String getLieuNom() { return lieuNom; }
    public void setLieuNom(String lieuNom) { this.lieuNom = lieuNom; }
    public String getSalleNom() { return salleNom; }
    public void setSalleNom(String salleNom) { this.salleNom = salleNom; }
    public String getRang() { return rang; }
    public void setRang(String rang) { this.rang = rang; }
    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public String getZoneNom() { return zoneNom; }
    public void setZoneNom(String zoneNom) { this.zoneNom = zoneNom; }
    public Integer getIdZone() { return idZone; }
    public void setIdZone(Integer idZone) { this.idZone = idZone; }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class QRResponse {
        private String codeTicket;
        private String qrCodeBase64;
        private String evenementTitre;
        private String placeNumero;
        private String rang;
        private String typePlace;
        private String prix;
        private String status;

        public QRResponse() {}

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

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ValidationResponse {
        private boolean valid;
        private String codeTicket;
        private String evenementTitre;
        private String placeNumero;
        private String clientNom;
        private String message;

        public ValidationResponse() {}

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

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class GateScanResponse {
        private String statut;
        private String message;
        private String codeTicket;
        private String evenementTitre;
        private String placeNumero;
        private String clientNom;

        public GateScanResponse() {}

        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
        public String getEvenementTitre() { return evenementTitre; }
        public void setEvenementTitre(String evenementTitre) { this.evenementTitre = evenementTitre; }
        public String getPlaceNumero() { return placeNumero; }
        public void setPlaceNumero(String placeNumero) { this.placeNumero = placeNumero; }
        public String getClientNom() { return clientNom; }
        public void setClientNom(String clientNom) { this.clientNom = clientNom; }
    }

    public static class Concerner {
        @NotNull(message = "Event ID is required")
        private Integer idEvenement;
        @NotBlank(message = "Ticket code is required")
        private String codeTicket;
        @NotBlank(message = "Place number is required")
        private String numeroPlace;

        public Concerner() {}

        public Integer getIdEvenement() { return idEvenement; }
        public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
    }
}
