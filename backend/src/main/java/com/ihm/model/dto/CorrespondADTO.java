package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CorrespondADTO {

    @NotBlank(message = "Ticket code is required")
    private String codeTicket;

    @NotNull(message = "Reservation ID is required")
    private Integer idReservation;

    public CorrespondADTO() {}

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }
}
