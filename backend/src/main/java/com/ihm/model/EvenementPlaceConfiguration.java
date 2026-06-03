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
    @Column(name = "typePlaceOverride", length = 50)
    private String typePlaceOverride;
    @Column(name = "prixOverride", precision = 10, scale = 2)
    private BigDecimal prixOverride;
    @Column(name = "statutPlace", length = 20)
    private String statutPlace = "LIBRE";
    public EvenementPlaceConfiguration() {}
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public Place getPlace() { return place; }
    public void setPlace(Place place) { this.place = place; }
    public String getTypePlaceOverride() { return typePlaceOverride; }
    public void setTypePlaceOverride(String typePlaceOverride) { this.typePlaceOverride = typePlaceOverride; }
    public BigDecimal getPrixOverride() { return prixOverride; }
    public void setPrixOverride(BigDecimal prixOverride) { this.prixOverride = prixOverride; }
    public String getStatutPlace() { return statutPlace; }
    public void setStatutPlace(String statutPlace) { this.statutPlace = statutPlace; }
}
