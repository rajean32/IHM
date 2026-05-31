package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class BatchPlaceRequest {

    @NotBlank(message = "Room number is required")
    private String numeroSalle;

    @Min(value = 1, message = "Number of rows must be >= 1")
    private int nombreRangees;

    @Min(value = 1, message = "Number of seats per row must be >= 1")
    private int placesParRangee;

    private String prefixeRangee = "";

    private String typePlace;

    private BigDecimal prix;

    private int debutNumero = 1;

    public BatchPlaceRequest() {}

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }

    public int getNombreRangees() { return nombreRangees; }
    public void setNombreRangees(int nombreRangees) { this.nombreRangees = nombreRangees; }

    public int getPlacesParRangee() { return placesParRangee; }
    public void setPlacesParRangee(int placesParRangee) { this.placesParRangee = placesParRangee; }

    public String getPrefixeRangee() { return prefixeRangee; }
    public void setPrefixeRangee(String prefixeRangee) { this.prefixeRangee = prefixeRangee; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }

    public int getDebutNumero() { return debutNumero; }
    public void setDebutNumero(int debutNumero) { this.debutNumero = debutNumero; }
}
