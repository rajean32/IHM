package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
public class DashboardDTO {
    private DashboardDTO() {}
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class AdminStats {
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
        public AdminStats() {}
        public long getTotalEvents() { return totalEvents; }
        public void setTotalEvents(long v) { totalEvents = v; }
        public long getTotalClients() { return totalClients; }
        public void setTotalClients(long v) { totalClients = v; }
        public long getTotalOrganisateurs() { return totalOrganisateurs; }
        public void setTotalOrganisateurs(long v) { totalOrganisateurs = v; }
        public long getTotalReservations() { return totalReservations; }
        public void setTotalReservations(long v) { totalReservations = v; }
        public long getTotalTicketsSold() { return totalTicketsSold; }
        public void setTotalTicketsSold(long v) { totalTicketsSold = v; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal v) { totalRevenue = v; }
        public long getTotalLieux() { return totalLieux; }
        public void setTotalLieux(long v) { totalLieux = v; }
        public long getTotalSalles() { return totalSalles; }
        public void setTotalSalles(long v) { totalSalles = v; }
        public List<EvenementDTO> getRecentEvents() { return recentEvents; }
        public void setRecentEvents(List<EvenementDTO> v) { recentEvents = v; }
        public List<Map<String, Object>> getTopEvents() { return topEvents; }
        public void setTopEvents(List<Map<String, Object>> v) { topEvents = v; }
        public Map<String, Long> getEventsByStatus() { return eventsByStatus; }
        public void setEventsByStatus(Map<String, Long> v) { eventsByStatus = v; }
        public Map<String, Long> getEventsByCategorie() { return eventsByCategorie; }
        public void setEventsByCategorie(Map<String, Long> v) { eventsByCategorie = v; }
    }
    public static class OrganizerStats {
        private String codeOrganisateur;
        private int totalEvents;
        private long totalTicketsSold;
        private long totalReservations;
        private BigDecimal totalRevenue;
        private long totalPlaces;
        private long placesDisponibles;
        private double fillRate;
        private List<EvenementDTO> myEvents;
        private List<EvenementDTO> topEvents;
        private List<DailySales> dailySales;
        public OrganizerStats() {}
        public String getCodeOrganisateur() { return codeOrganisateur; }
        public void setCodeOrganisateur(String v) { codeOrganisateur = v; }
        public int getTotalEvents() { return totalEvents; }
        public void setTotalEvents(int v) { totalEvents = v; }
        public long getTotalTicketsSold() { return totalTicketsSold; }
        public void setTotalTicketsSold(long v) { totalTicketsSold = v; }
        public long getTotalReservations() { return totalReservations; }
        public void setTotalReservations(long v) { totalReservations = v; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal v) { totalRevenue = v; }
        public long getTotalPlaces() { return totalPlaces; }
        public void setTotalPlaces(long v) { totalPlaces = v; }
        public long getPlacesDisponibles() { return placesDisponibles; }
        public void setPlacesDisponibles(long v) { placesDisponibles = v; }
        public double getFillRate() { return fillRate; }
        public void setFillRate(double v) { fillRate = v; }
        public List<EvenementDTO> getMyEvents() { return myEvents; }
        public void setMyEvents(List<EvenementDTO> v) { myEvents = v; }
        public List<EvenementDTO> getTopEvents() { return topEvents; }
        public void setTopEvents(List<EvenementDTO> v) { topEvents = v; }
        public List<DailySales> getDailySales() { return dailySales; }
        public void setDailySales(List<DailySales> v) { dailySales = v; }
    }
    public static class DailySales {
        private LocalDate date;
        private long ticketsSold;
        private double revenue;
        public DailySales() {}
        public DailySales(LocalDate date, long ticketsSold, double revenue) {
            this.date = date; this.ticketsSold = ticketsSold; this.revenue = revenue;
        }
        public LocalDate getDate() { return date; }
        public void setDate(LocalDate v) { date = v; }
        public long getTicketsSold() { return ticketsSold; }
        public void setTicketsSold(long v) { ticketsSold = v; }
        public double getRevenue() { return revenue; }
        public void setRevenue(double v) { revenue = v; }
    }
    public static class EventStats {
        private Integer idEvenement;
        private String titre;
        private long totalTickets;
        private long ticketsVendus;
        private long ticketsDisponibles;
        private long totalReservations;
        private BigDecimal totalRevenue;
        private String statut;
        private Map<String, Long> ticketsByType;
        public EventStats() {}
        public Integer getIdEvenement() { return idEvenement; }
        public void setIdEvenement(Integer v) { idEvenement = v; }
        public String getTitre() { return titre; }
        public void setTitre(String v) { titre = v; }
        public long getTotalTickets() { return totalTickets; }
        public void setTotalTickets(long v) { totalTickets = v; }
        public long getTicketsVendus() { return ticketsVendus; }
        public void setTicketsVendus(long v) { ticketsVendus = v; }
        public long getTicketsDisponibles() { return ticketsDisponibles; }
        public void setTicketsDisponibles(long v) { ticketsDisponibles = v; }
        public long getTotalReservations() { return totalReservations; }
        public void setTotalReservations(long v) { totalReservations = v; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal v) { totalRevenue = v; }
        public String getStatut() { return statut; }
        public void setStatut(String v) { statut = v; }
        public Map<String, Long> getTicketsByType() { return ticketsByType; }
        public void setTicketsByType(Map<String, Long> v) { ticketsByType = v; }
    }
}
