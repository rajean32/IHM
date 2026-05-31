package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.util.List;

public class PurchaseRequest {
    @NotBlank
    private String codeClient;
    @NotEmpty
    private List<PurchaseTicketItem> tickets;
    @NotBlank
    private String modePaiement;
    @Positive
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
        @NotBlank
        private String codeTicket;
        @NotBlank
        private String numeroPlace;
        private Integer idEvenement;
        private BigDecimal prix;

        public PurchaseTicketItem() {}

        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

        public Integer getIdEvenement() { return idEvenement; }
        public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }

        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
    }
}
