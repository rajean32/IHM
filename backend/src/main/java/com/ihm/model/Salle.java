package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "SALLE")
public class Salle {
    @Id
    @Column(name = "NumeroSalle", length = 50)
    private String numeroSalle;

    @Column(name = "NomSalle", length = 100, nullable = false)
    @NotBlank(message = "Room name is required")
    private String nomSalle;

    @Column(name = "type", length = 50)
    private String type;

    @Column(name = "capacite")
    private Integer capacite;

    @Column(name = "RangePlace", length = 50)
    private String range;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "codeLieu", referencedColumnName = "code", nullable = false)
    private Lieu lieu;

    @OneToMany(mappedBy = "salle", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Place> places = new ArrayList<>();

    @OneToMany(mappedBy = "salle", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<SalleTypeEvenement> typesEvenement = new ArrayList<>();

    public Salle() {}

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Integer getCapacite() { return capacite; }
    public void setCapacite(Integer capacite) { this.capacite = capacite; }
    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }
    public Lieu getLieu() { return lieu; }
    public void setLieu(Lieu lieu) { this.lieu = lieu; }
    public List<Place> getPlaces() { return places; }
    public void setPlaces(List<Place> places) { this.places = places; }
    public List<SalleTypeEvenement> getTypesEvenement() { return typesEvenement; }
    public void setTypesEvenement(List<SalleTypeEvenement> typesEvenement) { this.typesEvenement = typesEvenement; }
}
