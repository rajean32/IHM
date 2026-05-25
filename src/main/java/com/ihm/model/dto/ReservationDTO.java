package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotNull;

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
}
