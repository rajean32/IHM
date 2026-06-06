package com.ihm.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "EVENEMENT_PLACE_CONFIG",
       uniqueConstraints = @UniqueConstraint(columnNames = {"idEvenement", "NumeroPlace"}))
public class EvenementPlaceConfiguration {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idEvenement", referencedColumnName = "idEvenement", nullable = false)
    private Evenement evenement;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NumeroPlace", referencedColumnName = "NumeroPlace", nullable = false)
    private Place place;
    @Column(name = "typePlace", length = 50, nullable = false)
    private String typePlace;
    @Column(name = "prix", precision = 10, scale = 2, nullable = false)
    private BigDecimal prix;
    @Column(name = "range", length = 10, nullable = false)
    private String range;
    @Column(name = "statut", length = 20, nullable = false)
    private String statut = "DISPONIBLE";
    public EvenementPlaceConfiguration() {}
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public Place getPlace() { return place; }
    public void setPlace(Place place) { this.place = place; }
    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
}
