package com.ihm.model;

import jakarta.persistence.*;

@Entity
@Table(name = "EVENEMENT_CARACTERISTIQUE_VALEUR")
public class EvenementCaracteristiqueValeur {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idValeur")
    private Integer idValeur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idEvenement", referencedColumnName = "idEvenement", nullable = false)
    private Evenement evenement;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idCaracteristique", referencedColumnName = "idCaracteristique", nullable = false)
    private Caracteristique caracteristique;

    @Column(name = "valeur", columnDefinition = "TEXT")
    private String valeur;

    public EvenementCaracteristiqueValeur() {}

    public Integer getIdValeur() { return idValeur; }
    public void setIdValeur(Integer idValeur) { this.idValeur = idValeur; }
    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
    public Caracteristique getCaracteristique() { return caracteristique; }
    public void setCaracteristique(Caracteristique caracteristique) { this.caracteristique = caracteristique; }
    public String getValeur() { return valeur; }
    public void setValeur(String valeur) { this.valeur = valeur; }
}
