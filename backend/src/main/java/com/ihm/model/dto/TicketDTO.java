package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class TicketDTO {

    @NotBlank(message = "Ticket code is required")
    private String codeTicket;

    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be positive")
    private BigDecimal prix;

    private String numeroPlace;
    private Integer idEvenement;

    public TicketDTO() {}

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
}
