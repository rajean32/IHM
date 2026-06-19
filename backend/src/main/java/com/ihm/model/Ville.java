package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "VILLE")
public class Ville {
    @Id
    @Column(name = "code", length = 20)
    @NotBlank(message = "City code is required")
    private String code;

    @Column(name = "nom", length = 100, nullable = false)
    @NotBlank(message = "City name is required")
    private String nom;

    @Column(name = "region", length = 100)
    private String region;

    @Column(name = "actif")
    private boolean actif = true;

    public Ville() {}

    public Ville(String code, String nom) {
        this.code = code;
        this.nom = nom;
    }

    public Ville(String code, String nom, String region) {
        this.code = code;
        this.nom = nom;
        this.region = region;
    }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
}
