package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
@Entity
@Table(name = "CONCERNER")
public class Concerner {
    @EmbeddedId
    private ConcernerId id;
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idEvenement")
    @JoinColumn(name = "idEvenement", referencedColumnName = "idEvenement", nullable = false)
    @NotNull(message = "Event is required")
    private Evenement evenement;
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("codeTicket")
    @JoinColumn(name = "CodeTicket", referencedColumnName = "CodeTicket", nullable = false)
    @NotNull(message = "Ticket is required")
    private Ticket ticket;
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("numeroPlace")
    @JoinColumn(name = "NumeroPlace", referencedColumnName = "NumeroPlace", nullable = false)
    @NotNull(message = "Place is required")
    private Place place;
    public Concerner() {}
    public ConcernerId getId() { return id; }
    public void setId(ConcernerId id) { this.id = id; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public Ticket getTicket() { return ticket; }
    public void setTicket(Ticket ticket) { this.ticket = ticket; }
    public Place getPlace() { return place; }
    public void setPlace(Place place) { this.place = place; }
}
