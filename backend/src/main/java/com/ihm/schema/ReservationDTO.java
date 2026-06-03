package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ReservationDTO {
    private Integer idReservation;
    @NotNull(message = "Reservation date is required")
    private LocalDateTime dateReservation;
    @NotNull(message = "Client code is required")
    private String codeClient;
    private List<String> codeTickets;
    public ReservationDTO() {}
    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
    public LocalDateTime getDateReservation() { return dateReservation; }
    public void setDateReservation(LocalDateTime dateReservation) { this.dateReservation = dateReservation; }
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public List<String> getCodeTickets() { return codeTickets; }
    public void setCodeTickets(List<String> codeTickets) { this.codeTickets = codeTickets; }
    public static class PurchaseRequest {
        private String codeClient;
        private List<PurchaseTicketItem> tickets;
        private String modePaiement;
        private BigDecimal montant;
        public PurchaseRequest() {}
        public String getCodeClient() { return codeClient; }
        public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
        public List<PurchaseTicketItem> getTickets() { return tickets; }
        public void setTickets(List<PurchaseTicketItem> tickets) { this.tickets = tickets; }
        public String getModePaiement() { return modePaiement; }
        public void setModePaiement(String modePaiement) { this.modePaiement = modePaiement; }
        public BigDecimal getMontant() { return montant; }
        public void setMontant(BigDecimal montant) { this.montant = montant; }
        public static class PurchaseTicketItem {
            private String codeTicket;
            private String numeroPlace;
            private Integer idEvenement;
            private BigDecimal prix;
            private String idPlaceCombine;
            public PurchaseTicketItem() {}
            public String getCodeTicket() { return codeTicket; }
            public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
            public String getNumeroPlace() { return numeroPlace; }
            public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
            public Integer getIdEvenement() { return idEvenement; }
            public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
            public BigDecimal getPrix() { return prix; }
            public void setPrix(BigDecimal prix) { this.prix = prix; }
            public String getIdPlaceCombine() { return idPlaceCombine; }
            public void setIdPlaceCombine(String idPlaceCombine) { this.idPlaceCombine = idPlaceCombine; }
        }
    }
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class CancelResponse {
        private Integer idReservation;
        private String status;
        private BigDecimal refundAmount;
        private String message;
        public CancelResponse() {}
        public Integer getIdReservation() { return idReservation; }
        public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public BigDecimal getRefundAmount() { return refundAmount; }
        public void setRefundAmount(BigDecimal refundAmount) { this.refundAmount = refundAmount; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
    public static class CorrespondA {
        @NotBlank(message = "Ticket code is required")
        private String codeTicket;
        @NotNull(message = "Reservation ID is required")
        private Integer idReservation;
        public CorrespondA() {}
        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
        public Integer getIdReservation() { return idReservation; }
        public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
    }
}
