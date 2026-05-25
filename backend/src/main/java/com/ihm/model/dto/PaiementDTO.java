package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaiementDTO {

    private Integer idPaiement;

    @DecimalMin(value = "0.0", inclusive = false, message = "Amount must be positive")
    private BigDecimal montant;

    @NotNull(message = "Payment date is required")
    private LocalDateTime datePaiement;

    @NotBlank(message = "Payment method is required")
    private String modePaiement;

    @NotNull(message = "Reservation ID is required")
    private Integer idReservation;

    public PaiementDTO() {}

    public Integer getIdPaiement() { return idPaiement; }
    public void setIdPaiement(Integer idPaiement) { this.idPaiement = idPaiement; }

    public BigDecimal getMontant() { return montant; }
    public void setMontant(BigDecimal montant) { this.montant = montant; }

    public LocalDateTime getDatePaiement() { return datePaiement; }
    public void setDatePaiement(LocalDateTime datePaiement) { this.datePaiement = datePaiement; }

    public String getModePaiement() { return modePaiement; }
    public void setModePaiement(String modePaiement) { this.modePaiement = modePaiement; }

    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
}
