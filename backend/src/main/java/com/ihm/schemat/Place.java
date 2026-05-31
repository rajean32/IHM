package com.ihm.schemat;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "PLACE")
public class Place {

    @Id
    @Column(name = "NumeroPlace", length = 50)
    @NotBlank(message = "Place number is required")
    private String numeroPlace;

    @Column(name = "\"range\"", length = 10)
    private String range;

    @Column(name = "typePlace", length = 50)
    private String typePlace;

    @Column(name = "prix", precision = 10, scale = 2)
    private BigDecimal prix;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", length = 20, nullable = false)
    private StatutPlace statut = StatutPlace.DISPONIBLE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NumeroSalle", referencedColumnName = "NumeroSalle", nullable = false)
    private Salle salle;

    @OneToMany(mappedBy = "place", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Concerner> concerners = new ArrayList<>();

    public Place() {}

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public StatutPlace getStatut() { return statut; }
    public void setStatut(StatutPlace statut) { this.statut = statut; }

    public Salle getSalle() { return salle; }
    public void setSalle(Salle salle) { this.salle = salle; }

    public List<Concerner> getConcerners() { return concerners; }
    public void setConcerners(List<Concerner> concerners) { this.concerners = concerners; }
}
