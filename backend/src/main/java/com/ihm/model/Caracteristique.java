package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "CARACTERISTIQUE")
public class Caracteristique {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idCaracteristique")
    private Integer idCaracteristique;

    @Column(name = "nom", length = 100, nullable = false)
    @NotBlank(message = "Characteristic name is required")
    private String nom;

    @Column(name = "typeDonnee", length = 50, nullable = false)
    private String typeDonnee;

    @Column(name = "obligatoire", nullable = false)
    private boolean obligatoire;

    @Column(name = "ordreAffichage")
    private Integer ordreAffichage;

    @Column(name = "options", columnDefinition = "TEXT")
    private String options;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "codeCategorie", referencedColumnName = "codeCategorie", nullable = false)
    private Categorie categorie;

    public Caracteristique() {}

    public Integer getIdCaracteristique() { return idCaracteristique; }
    public void setIdCaracteristique(Integer idCaracteristique) { this.idCaracteristique = idCaracteristique; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getTypeDonnee() { return typeDonnee; }
    public void setTypeDonnee(String typeDonnee) { this.typeDonnee = typeDonnee; }
    public boolean isObligatoire() { return obligatoire; }
    public void setObligatoire(boolean obligatoire) { this.obligatoire = obligatoire; }
    public Integer getOrdreAffichage() { return ordreAffichage; }
    public void setOrdreAffichage(Integer ordreAffichage) { this.ordreAffichage = ordreAffichage; }
    public String getOptions() { return options; }
    public void setOptions(String options) { this.options = options; }
    public Categorie getCategorie() { return categorie; }
    public void setCategorie(Categorie categorie) { this.categorie = categorie; }
}
