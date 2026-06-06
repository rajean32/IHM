package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "PLACE")
public class Place {
    @Id
    @Column(name = "NumeroPlace", length = 50)
    @NotBlank(message = "Place number is required")
    private String numeroPlace;
    
    @Column(name = "RangePlace", length = 50)
    @NotBlank(message = "Place range is required")
    private String rangePlace;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NumeroSalle", referencedColumnName = "NumeroSalle", nullable = false)
    private Salle salle;
    public Place() {}
    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
    public String getRangePlace() { return rangePlace; }
    public void setRangePlace(String rangePlace) { this.rangePlace = rangePlace; }
    public Salle getSalle() { return salle; }
    public void setSalle(Salle salle) { this.salle = salle; }
}
