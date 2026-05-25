package com.ihm.schemat;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

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

    @OneToMany(mappedBy = "categorie", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Evenement> evenements = new ArrayList<>();

    public Categorie() {}

    public Categorie(String codeCategorie, String nomCategorie) {
        this.codeCategorie = codeCategorie;
        this.nomCategorie = nomCategorie;
    }

    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }

    public String getNomCategorie() { return nomCategorie; }
    public void setNomCategorie(String nomCategorie) { this.nomCategorie = nomCategorie; }

    public List<Evenement> getEvenements() { return evenements; }
    public void setEvenements(List<Evenement> evenements) { this.evenements = evenements; }
}
