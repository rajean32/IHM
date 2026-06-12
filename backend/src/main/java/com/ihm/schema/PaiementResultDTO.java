package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaiementResultDTO {
    private boolean success;
    private String message;
    private Integer idReservation;
    private Integer idPaiement;
    private BigDecimal montantInitial;
    private BigDecimal reductionAppliquee;
    private BigDecimal montantFinal;
    private String typeReduction;
    private String statutPaiement;
    private LocalDateTime datePaiement;

    public PaiementResultDTO() {}

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
    public Integer getIdPaiement() { return idPaiement; }
    public void setIdPaiement(Integer idPaiement) { this.idPaiement = idPaiement; }
    public BigDecimal getMontantInitial() { return montantInitial; }
    public void setMontantInitial(BigDecimal montantInitial) { this.montantInitial = montantInitial; }
    public BigDecimal getReductionAppliquee() { return reductionAppliquee; }
    public void setReductionAppliquee(BigDecimal reductionAppliquee) { this.reductionAppliquee = reductionAppliquee; }
    public BigDecimal getMontantFinal() { return montantFinal; }
    public void setMontantFinal(BigDecimal montantFinal) { this.montantFinal = montantFinal; }
    public String getTypeReduction() { return typeReduction; }
    public void setTypeReduction(String typeReduction) { this.typeReduction = typeReduction; }
    public String getStatutPaiement() { return statutPaiement; }
    public void setStatutPaiement(String statutPaiement) { this.statutPaiement = statutPaiement; }
    public LocalDateTime getDatePaiement() { return datePaiement; }
    public void setDatePaiement(LocalDateTime datePaiement) { this.datePaiement = datePaiement; }
}