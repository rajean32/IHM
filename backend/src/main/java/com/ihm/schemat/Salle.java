package com.ihm.schemat;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "SALLE")
public class Salle {

    @Id
    @Column(name = "NumeroSalle", length = 50)
    @NotBlank(message = "Room number is required")
    private String numeroSalle;

    @Column(name = "NomSalle", length = 100, nullable = false)
    @NotBlank(message = "Room name is required")
    private String nomSalle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idLieu", referencedColumnName = "idLieu", nullable = false)
    private Lieu lieu;

    @OneToMany(mappedBy = "salle", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Place> places = new ArrayList<>();

    public Salle() {}

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }

    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }

    public Lieu getLieu() { return lieu; }
    public void setLieu(Lieu lieu) { this.lieu = lieu; }

    public List<Place> getPlaces() { return places; }
    public void setPlaces(List<Place> places) { this.places = places; }
}
