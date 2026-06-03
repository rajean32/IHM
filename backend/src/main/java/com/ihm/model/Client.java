package com.ihm.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
@Entity
@Table(name = "CLIENT")
@PrimaryKeyJoinColumn(name = "CodeClient", referencedColumnName = "CodeUtilisateur")
public class Client extends Utilisateur {
    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Reservation> reservations = new ArrayList<>();
    public Client() {}
    public List<Reservation> getReservations() { return reservations; }
    public void setReservations(List<Reservation> reservations) { this.reservations = reservations; }
}
