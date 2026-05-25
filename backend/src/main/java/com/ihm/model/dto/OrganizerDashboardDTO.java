package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class OrganizerDashboardDTO {

    private String codeOrganisateur;
    private long totalEvents;
    private long totalTicketsSold;
    private long totalReservations;
    private BigDecimal totalRevenue;
    private long totalPlaces;
    private long placesDisponibles;
    private List<EvenementDTO> myEvents;

    public OrganizerDashboardDTO() {}

    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }

    public long getTotalEvents() { return totalEvents; }
    public void setTotalEvents(long totalEvents) { this.totalEvents = totalEvents; }

    public long getTotalTicketsSold() { return totalTicketsSold; }
    public void setTotalTicketsSold(long totalTicketsSold) { this.totalTicketsSold = totalTicketsSold; }

    public long getTotalReservations() { return totalReservations; }
    public void setTotalReservations(long totalReservations) { this.totalReservations = totalReservations; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public long getTotalPlaces() { return totalPlaces; }
    public void setTotalPlaces(long totalPlaces) { this.totalPlaces = totalPlaces; }

    public long getPlacesDisponibles() { return placesDisponibles; }
    public void setPlacesDisponibles(long placesDisponibles) { this.placesDisponibles = placesDisponibles; }

    public List<EvenementDTO> getMyEvents() { return myEvents; }
    public void setMyEvents(List<EvenementDTO> myEvents) { this.myEvents = myEvents; }
}
