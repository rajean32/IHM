package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
@Entity
@Table(name = "CORRESPOND_A")
public class CorrespondA {
    @EmbeddedId
    private CorrespondAId id;
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("codeTicket")
    @JoinColumn(name = "CodeTicket", referencedColumnName = "CodeTicket", nullable = false)
    @NotNull(message = "Ticket is required")
    private Ticket ticket;
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idReservation")
    @JoinColumn(name = "idReservation", referencedColumnName = "idReservation", nullable = false)
    @NotNull(message = "Reservation is required")
    private Reservation reservation;
    public CorrespondA() {}
    public CorrespondAId getId() { return id; }
    public void setId(CorrespondAId id) { this.id = id; }
    public Ticket getTicket() { return ticket; }
    public void setTicket(Ticket ticket) { this.ticket = ticket; }
    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }
}
