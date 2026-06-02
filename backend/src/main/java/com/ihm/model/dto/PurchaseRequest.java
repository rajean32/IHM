package com.ihm.model.dto;

import java.math.BigDecimal;
import java.util.List;

public class PurchaseRequest {

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
