package com.ihm.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "PAIEMENT_TRANSACTION")
public class PaiementTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idTransaction")
    private Long idTransaction;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idPaiement", referencedColumnName = "idPaiement", nullable = false)
    private Paiement paiement;

    @Column(name = "referenceTransaction", length = 100)
    private String referenceTransaction;

    @Column(name = "numeroTelephone", length = 20)
    private String numeroTelephone;

    @Column(name = "nomComplet", length = 100)
    private String nomComplet;

    @Column(name = "statut", length = 50, nullable = false)
    private String statut = "EN_ATTENTE";

    @Column(name = "messageReponse", columnDefinition = "TEXT")
    private String messageReponse;

    @Column(name = "dateTransaction")
    private LocalDateTime dateTransaction;

    public PaiementTransaction() {}

    // Getters et Setters
    public Long getIdTransaction() { return idTransaction; }
    public void setIdTransaction(Long idTransaction) { this.idTransaction = idTransaction; }

    public Paiement getPaiement() { return paiement; }
    public void setPaiement(Paiement paiement) { this.paiement = paiement; }

    public String getReferenceTransaction() { return referenceTransaction; }
    public void setReferenceTransaction(String referenceTransaction) { this.referenceTransaction = referenceTransaction; }

    public String getNumeroTelephone() { return numeroTelephone; }
    public void setNumeroTelephone(String numeroTelephone) { this.numeroTelephone = numeroTelephone; }

    public String getNomComplet() { return nomComplet; }
    public void setNomComplet(String nomComplet) { this.nomComplet = nomComplet; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getMessageReponse() { return messageReponse; }
    public void setMessageReponse(String messageReponse) { this.messageReponse = messageReponse; }

    public LocalDateTime getDateTransaction() { return dateTransaction; }
    public void setDateTransaction(LocalDateTime dateTransaction) { this.dateTransaction = dateTransaction; }
}