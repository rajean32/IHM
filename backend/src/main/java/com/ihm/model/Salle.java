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
    @Column(name = "RangePlace", length = 50)
    private String range;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "codeLieu", referencedColumnName = "code", nullable = false)
    private Lieu lieu;
    @OneToMany(mappedBy = "salle", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    
    private List<Place> places = new ArrayList<>();
    public Salle() {}
    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }
    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }
    public Lieu getLieu() { return lieu; }
    public void setLieu(Lieu lieu) { this.lieu = lieu; }
    public List<Place> getPlaces() { return places; }
    public void setPlaces(List<Place> places) { this.places = places; }
}
