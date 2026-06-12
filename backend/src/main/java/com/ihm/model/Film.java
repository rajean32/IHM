package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "FILM")
public class Film {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idFilm")
    private Long idFilm;

    @Column(name = "titre", length = 200, nullable = false)
    @NotBlank(message = "Le titre du film est requis")
    private String titre;

    @Column(name = "synopsis", columnDefinition = "TEXT")
    private String synopsis;

    @Column(name = "realisateur", length = 100)
    private String realisateur;

    @Column(name = "acteurs", columnDefinition = "TEXT")
    private String acteurs;

    @Column(name = "dureeMinutes")
    private Integer dureeMinutes;

    @Column(name = "affiche", columnDefinition = "BYTEA")
    private byte[] affiche;

    @Column(name = "bandeAnnonce", length = 500)
    private String bandeAnnonce;

    @OneToMany(mappedBy = "film", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<SeanceCinema> seances = new ArrayList<>();

    public Film() {}

    // Getters et Setters
    public Long getIdFilm() { return idFilm; }
    public void setIdFilm(Long idFilm) { this.idFilm = idFilm; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getSynopsis() { return synopsis; }
    public void setSynopsis(String synopsis) { this.synopsis = synopsis; }

    public String getRealisateur() { return realisateur; }
    public void setRealisateur(String realisateur) { this.realisateur = realisateur; }

    public String getActeurs() { return acteurs; }
    public void setActeurs(String acteurs) { this.acteurs = acteurs; }

    public Integer getDureeMinutes() { return dureeMinutes; }
    public void setDureeMinutes(Integer dureeMinutes) { this.dureeMinutes = dureeMinutes; }

    public byte[] getAffiche() { return affiche; }
    public void setAffiche(byte[] affiche) { this.affiche = affiche; }

    public String getBandeAnnonce() { return bandeAnnonce; }
    public void setBandeAnnonce(String bandeAnnonce) { this.bandeAnnonce = bandeAnnonce; }

    public List<SeanceCinema> getSeances() { return seances; }
    public void setSeances(List<SeanceCinema> seances) { this.seances = seances; }
}