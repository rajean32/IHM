package com.ihm.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "ZONE_STANDING")
public class ZoneStanding {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_zone")
    private Integer idZone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_evenement", nullable = false)
    private Evenement evenement;

    @Column(name = "nom", length = 100, nullable = false)
    private String nom;

    @Column(name = "capacite")
    private Integer capacite;

    @Column(name = "prix", precision = 10, scale = 2, nullable = false)
    private BigDecimal prix;

    @Column(name = "statut", length = 20)
    private String statut = "ACTIVE";

    @Column(name = "reservations_actuelles")
    private Integer reservationsActuelles = 0;

    public ZoneStanding() {}

    public Integer getIdZone() { return idZone; }
    public void setIdZone(Integer idZone) { this.idZone = idZone; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Integer getCapacite() { return capacite; }
    public void setCapacite(Integer capacite) { this.capacite = capacite; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public Integer getReservationsActuelles() { return reservationsActuelles; }
    public void setReservationsActuelles(Integer reservationsActuelles) { this.reservationsActuelles = reservationsActuelles; }
}
