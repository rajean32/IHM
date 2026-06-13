package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "SEANCE_CINEMA")
public class SeanceCinema {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idSeance")
    private Long idSeance;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idFilm", nullable = false)
    private Film film;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idEvenement", referencedColumnName = "idEvenement", nullable = false)
    private Evenement evenement;

    @Column(name = "dateSeance", nullable = false)
    @NotNull(message = "La date de séance est requise")
    private LocalDate dateSeance;

    @Column(name = "heureSeance", nullable = false)
    @NotNull(message = "L'heure de séance est requise")
    private LocalTime heureSeance;

    @Column(name = "version", length = 20)
    private String version;

    @Column(name = "langue", length = 50)
    private String langue;

    @Column(name = "sousTitres", length = 50)
    private String sousTitres;

    public SeanceCinema() {}

    // Getters et Setters
    public Long getIdSeance() { return idSeance; }
    public void setIdSeance(Long idSeance) { this.idSeance = idSeance; }

    public Film getFilm() { return film; }
    public void setFilm(Film film) { this.film = film; }

    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }

    public LocalDate getDateSeance() { return dateSeance; }
    public void setDateSeance(LocalDate dateSeance) { this.dateSeance = dateSeance; }

    public LocalTime getHeureSeance() { return heureSeance; }
    public void setHeureSeance(LocalTime heureSeance) { this.heureSeance = heureSeance; }

    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }

    public String getLangue() { return langue; }
    public void setLangue(String langue) { this.langue = langue; }

    public String getSousTitres() { return sousTitres; }
    public void setSousTitres(String sousTitres) { this.sousTitres = sousTitres; }
}