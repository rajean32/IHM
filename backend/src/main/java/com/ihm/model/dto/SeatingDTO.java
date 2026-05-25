package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class SeatingDTO {

    private String numeroPlace;
    private String rang;
    private String typePlace;
    private boolean disponible;
    private BigDecimal prix;
    private String salle;

    public SeatingDTO() {}

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

    public String getRang() { return rang; }
    public void setRang(String rang) { this.rang = rang; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public String getSalle() { return salle; }
    public void setSalle(String salle) { this.salle = salle; }
}
