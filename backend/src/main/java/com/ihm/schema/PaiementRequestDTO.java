package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaiementRequestDTO {

    @NotNull(message = "Le code client est requis")
    private String codeClient;

    @NotNull(message = "La liste des tickets est requise")
    private List<TicketItem> tickets;

    @NotNull(message = "Le type de paiement est requis")
    private String typePaiement;

    private String referenceTransaction;
    private String numeroTelephone;
    private String nomComplet;
    private CarteBancaireDTO carte;
    private String codePromo;
    private Boolean estEtudiant;

    public static class TicketItem {
        private String codeTicket;
        private String numeroPlace;
        private Integer idEvenement;
        private BigDecimal prix;
        private Integer idZone;

        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
        public Integer getIdEvenement() { return idEvenement; }
        public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
        public Integer getIdZone() { return idZone; }
        public void setIdZone(Integer idZone) { this.idZone = idZone; }
    }

    public static class CarteBancaireDTO {
        private String numeroCarte;
        private String dateExpiration;
        private String cvv;
        private String nomTitulaire;

        public String getNumeroCarte() { return numeroCarte; }
        public void setNumeroCarte(String numeroCarte) { this.numeroCarte = numeroCarte; }
        public String getDateExpiration() { return dateExpiration; }
        public void setDateExpiration(String dateExpiration) { this.dateExpiration = dateExpiration; }
        public String getCvv() { return cvv; }
        public void setCvv(String cvv) { this.cvv = cvv; }
        public String getNomTitulaire() { return nomTitulaire; }
        public void setNomTitulaire(String nomTitulaire) { this.nomTitulaire = nomTitulaire; }
    }

    // Getters et Setters
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public List<TicketItem> getTickets() { return tickets; }
    public void setTickets(List<TicketItem> tickets) { this.tickets = tickets; }
    public String getTypePaiement() { return typePaiement; }
    public void setTypePaiement(String typePaiement) { this.typePaiement = typePaiement; }
    public String getReferenceTransaction() { return referenceTransaction; }
    public void setReferenceTransaction(String referenceTransaction) { this.referenceTransaction = referenceTransaction; }
    public String getNumeroTelephone() { return numeroTelephone; }
    public void setNumeroTelephone(String numeroTelephone) { this.numeroTelephone = numeroTelephone; }
    public String getNomComplet() { return nomComplet; }
    public void setNomComplet(String nomComplet) { this.nomComplet = nomComplet; }
    public CarteBancaireDTO getCarte() { return carte; }
    public void setCarte(CarteBancaireDTO carte) { this.carte = carte; }
    public String getCodePromo() { return codePromo; }
    public void setCodePromo(String codePromo) { this.codePromo = codePromo; }
    public Boolean getEstEtudiant() { return estEtudiant; }
    public void setEstEtudiant(Boolean estEtudiant) { this.estEtudiant = estEtudiant; }
}