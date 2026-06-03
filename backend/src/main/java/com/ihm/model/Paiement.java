package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
@Entity
@Table(name = "PAIEMENT")
public class Paiement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idPaiement")
    private Integer idPaiement;
    @Column(name = "montant", precision = 10, scale = 2, nullable = false)
    @DecimalMin(value = "0.0", inclusive = true, message = "Amount must be positive")
    private BigDecimal montant;
    @Column(name = "datePaiement", nullable = false)
    @NotNull(message = "Payment date is required")
    private LocalDateTime datePaiement;
    @Column(name = "modePaiement", length = 50, nullable = false)
    @NotBlank(message = "Payment method is required")
    private String modePaiement;
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idReservation", referencedColumnName = "idReservation", unique = true, nullable = false)
    private Reservation reservation;
    public Paiement() {}
    public Integer getIdPaiement() { return idPaiement; }
    public void setIdPaiement(Integer idPaiement) { this.idPaiement = idPaiement; }
    public BigDecimal getMontant() { return montant; }
    public void setMontant(BigDecimal montant) { this.montant = montant; }
    public LocalDateTime getDatePaiement() { return datePaiement; }
    public void setDatePaiement(LocalDateTime datePaiement) { this.datePaiement = datePaiement; }
    public String getModePaiement() { return modePaiement; }
    public void setModePaiement(String modePaiement) { this.modePaiement = modePaiement; }
    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }
}
