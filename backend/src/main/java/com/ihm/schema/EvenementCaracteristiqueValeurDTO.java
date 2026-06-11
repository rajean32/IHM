package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EvenementCaracteristiqueValeurDTO {
    private Integer idValeur;
    private Integer idEvenement;
    private Integer idCaracteristique;
    private String nomCaracteristique;
    private String typeDonnee;
    private String valeur;

    public EvenementCaracteristiqueValeurDTO() {}

    public Integer getIdValeur() { return idValeur; }
    public void setIdValeur(Integer idValeur) { this.idValeur = idValeur; }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public Integer getIdCaracteristique() { return idCaracteristique; }
    public void setIdCaracteristique(Integer idCaracteristique) { this.idCaracteristique = idCaracteristique; }
    public String getNomCaracteristique() { return nomCaracteristique; }
    public void setNomCaracteristique(String nomCaracteristique) { this.nomCaracteristique = nomCaracteristique; }
    public String getTypeDonnee() { return typeDonnee; }
    public void setTypeDonnee(String typeDonnee) { this.typeDonnee = typeDonnee; }
    public String getValeur() { return valeur; }
    public void setValeur(String valeur) { this.valeur = valeur; }
}
