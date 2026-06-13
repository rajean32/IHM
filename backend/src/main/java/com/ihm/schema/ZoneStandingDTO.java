package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ZoneStandingDTO {

    private Integer idZone;
    private Integer idEvenement;
    private String nom;
    private Integer capacite;
    private BigDecimal prix;
    private String statut;
    private Integer reservationsActuelles;
    private Integer placesDisponibles;

    public ZoneStandingDTO() {}

    public Integer getIdZone() { return idZone; }
    public void setIdZone(Integer idZone) { this.idZone = idZone; }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
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
    public Integer getPlacesDisponibles() { return placesDisponibles; }
    public void setPlacesDisponibles(Integer placesDisponibles) { this.placesDisponibles = placesDisponibles; }
}
