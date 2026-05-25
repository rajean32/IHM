package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EventStatsDTO {

    private Integer idEvenement;
    private String titre;
    private long totalTickets;
    private long ticketsVendus;
    private long ticketsDisponibles;
    private BigDecimal totalRevenue;
    private long totalReservations;
    private String statut;
    private Map<String, Long> ticketsByType;

    public EventStatsDTO() {}

    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public long getTotalTickets() { return totalTickets; }
    public void setTotalTickets(long totalTickets) { this.totalTickets = totalTickets; }

    public long getTicketsVendus() { return ticketsVendus; }
    public void setTicketsVendus(long ticketsVendus) { this.ticketsVendus = ticketsVendus; }

    public long getTicketsDisponibles() { return ticketsDisponibles; }
    public void setTicketsDisponibles(long ticketsDisponibles) { this.ticketsDisponibles = ticketsDisponibles; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public long getTotalReservations() { return totalReservations; }
    public void setTotalReservations(long totalReservations) { this.totalReservations = totalReservations; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public Map<String, Long> getTicketsByType() { return ticketsByType; }
    public void setTicketsByType(Map<String, Long> ticketsByType) { this.ticketsByType = ticketsByType; }
}
