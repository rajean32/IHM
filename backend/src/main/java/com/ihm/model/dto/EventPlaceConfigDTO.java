package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EventPlaceConfigDTO {

    private String numeroPlace;
    private String range;
    private String typePlace;
    private BigDecimal prix;
    private String statut;
    private String numeroSalle;
    private String nomSalle;
    private String typePlaceOverride;
    private BigDecimal prixOverride;
    private String statutPlace;

    public EventPlaceConfigDTO() {}

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }

    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }

    public String getTypePlaceOverride() { return typePlaceOverride; }
    public void setTypePlaceOverride(String typePlaceOverride) { this.typePlaceOverride = typePlaceOverride; }

    public BigDecimal getPrixOverride() { return prixOverride; }
    public void setPrixOverride(BigDecimal prixOverride) { this.prixOverride = prixOverride; }

    public String getStatutPlace() { return statutPlace; }
    public void setStatutPlace(String statutPlace) { this.statutPlace = statutPlace; }
}
