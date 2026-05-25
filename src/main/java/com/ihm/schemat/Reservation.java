package com.ihm.schemat;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "RESERVATION")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idReservation")
    private Integer idReservation;

    @Column(name = "dateReservation", nullable = false)
    @NotNull(message = "Reservation date is required")
    private LocalDateTime dateReservation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeClient", referencedColumnName = "CodeClient", nullable = false)
    private Client client;

    @OneToOne(mappedBy = "reservation", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Paiement paiement;

    @OneToMany(mappedBy = "reservation", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CorrespondA> correspondances = new ArrayList<>();

    public Reservation() {}

    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }

    public LocalDateTime getDateReservation() { return dateReservation; }
    public void setDateReservation(LocalDateTime dateReservation) { this.dateReservation = dateReservation; }

    public Client getClient() { return client; }
    public void setClient(Client client) { this.client = client; }

    public Paiement getPaiement() { return paiement; }
    public void setPaiement(Paiement paiement) { this.paiement = paiement; }

    public List<CorrespondA> getCorrespondances() { return correspondances; }
    public void setCorrespondances(List<CorrespondA> correspondances) { this.correspondances = correspondances; }
}
