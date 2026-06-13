package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class CaracteristiqueDTO {
    private Integer idCaracteristique;
    @NotBlank(message = "Characteristic name is required")
    private String nom;
    @NotBlank(message = "Data type is required")
    private String typeDonnee;
    private boolean obligatoire;
    private Integer ordreAffichage;
    private String options;
    private String codeCategorie;

    public CaracteristiqueDTO() {}

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
    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
}
