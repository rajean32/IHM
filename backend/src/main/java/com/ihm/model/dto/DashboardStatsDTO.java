package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class DashboardStatsDTO {

    private long totalEvents;
    private long totalClients;
    private long totalOrganisateurs;
    private long totalReservations;
    private long totalTicketsSold;
    private BigDecimal totalRevenue;
    private long totalLieux;
    private long totalSalles;
    private List<EvenementDTO> recentEvents;
    private List<Map<String, Object>> topEvents;
    private Map<String, Long> eventsByStatus;
    private Map<String, Long> eventsByCategorie;

    public DashboardStatsDTO() {}

    public long getTotalEvents() { return totalEvents; }
    public void setTotalEvents(long totalEvents) { this.totalEvents = totalEvents; }

    public long getTotalClients() { return totalClients; }
    public void setTotalClients(long totalClients) { this.totalClients = totalClients; }

    public long getTotalOrganisateurs() { return totalOrganisateurs; }
    public void setTotalOrganisateurs(long totalOrganisateurs) { this.totalOrganisateurs = totalOrganisateurs; }

    public long getTotalReservations() { return totalReservations; }
    public void setTotalReservations(long totalReservations) { this.totalReservations = totalReservations; }

    public long getTotalTicketsSold() { return totalTicketsSold; }
    public void setTotalTicketsSold(long totalTicketsSold) { this.totalTicketsSold = totalTicketsSold; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public long getTotalLieux() { return totalLieux; }
    public void setTotalLieux(long totalLieux) { this.totalLieux = totalLieux; }

    public long getTotalSalles() { return totalSalles; }
    public void setTotalSalles(long totalSalles) { this.totalSalles = totalSalles; }

    public List<EvenementDTO> getRecentEvents() { return recentEvents; }
    public void setRecentEvents(List<EvenementDTO> recentEvents) { this.recentEvents = recentEvents; }

    public List<Map<String, Object>> getTopEvents() { return topEvents; }
    public void setTopEvents(List<Map<String, Object>> topEvents) { this.topEvents = topEvents; }

    public Map<String, Long> getEventsByStatus() { return eventsByStatus; }
    public void setEventsByStatus(Map<String, Long> eventsByStatus) { this.eventsByStatus = eventsByStatus; }

    public Map<String, Long> getEventsByCategorie() { return eventsByCategorie; }
    public void setEventsByCategorie(Map<String, Long> eventsByCategorie) { this.eventsByCategorie = eventsByCategorie; }
}
