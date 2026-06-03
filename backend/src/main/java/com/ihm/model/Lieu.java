package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;
@Entity
@Table(name = "LIEU")
public class Lieu {
    @Id
    @Column(name = "code", length = 50)
    private String code;
    @Column(name = "NomLieu", length = 150, nullable = false)
    @NotBlank(message = "Location name is required")
    private String nomLieu;
    @Column(name = "adresse", length = 255)
    private String adresse;
    @Column(name = "ville", length = 100)
    private String ville;
    @OneToMany(mappedBy = "lieu", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Salle> salles = new ArrayList<>();
    @OneToMany(mappedBy = "lieu", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Evenement> evenements = new ArrayList<>();
    public Lieu() {}
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getNomLieu() { return nomLieu; }
    public void setNomLieu(String nomLieu) { this.nomLieu = nomLieu; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }
    public List<Salle> getSalles() { return salles; }
    public void setSalles(List<Salle> salles) { this.salles = salles; }
    public List<Evenement> getEvenements() { return evenements; }
    public void setEvenements(List<Evenement> evenements) { this.evenements = evenements; }
}
