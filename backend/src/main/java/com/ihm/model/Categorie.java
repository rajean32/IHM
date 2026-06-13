package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "CATEGORIE")
public class Categorie {
    @Id
    @Column(name = "CodeCategorie", length = 50)
    @NotBlank(message = "Category code is required")
    private String codeCategorie;

    @Column(name = "NomCategorie", length = 100, nullable = false)
    @NotBlank(message = "Category name is required")
    private String nomCategorie;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "dateCreation")
    private LocalDateTime dateCreation;

    @OneToMany(mappedBy = "categorie", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Evenement> evenements = new ArrayList<>();

    @OneToMany(mappedBy = "categorie", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Caracteristique> caracteristiques = new ArrayList<>();

    @OneToMany(mappedBy = "categorie", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<SalleTypeEvenement> salleTypes = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "type_agencement", length = 50)
    private TypeAgencement typeAgencement;

    @Column(name = "specificConfig", columnDefinition = "TEXT")
    private String specificConfig;

    public Categorie() {}

    public Categorie(String codeCategorie, String nomCategorie) {
        this.codeCategorie = codeCategorie;
        this.nomCategorie = nomCategorie;
    }

    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
    public String getNomCategorie() { return nomCategorie; }
    public void setNomCategorie(String nomCategorie) { this.nomCategorie = nomCategorie; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
    public List<Evenement> getEvenements() { return evenements; }
    public void setEvenements(List<Evenement> evenements) { this.evenements = evenements; }
    public List<Caracteristique> getCaracteristiques() { return caracteristiques; }
    public void setCaracteristiques(List<Caracteristique> caracteristiques) { this.caracteristiques = caracteristiques; }
    public List<SalleTypeEvenement> getSalleTypes() { return salleTypes; }
    public void setSalleTypes(List<SalleTypeEvenement> salleTypes) { this.salleTypes = salleTypes; }
    public TypeAgencement getTypeAgencement() { return typeAgencement; }
    public void setTypeAgencement(TypeAgencement typeAgencement) { this.typeAgencement = typeAgencement; }
    public String getSpecificConfig() { return specificConfig; }
    public void setSpecificConfig(String specificConfig) { this.specificConfig = specificConfig; }
}
