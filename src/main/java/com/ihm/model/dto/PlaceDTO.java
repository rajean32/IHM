package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PlaceDTO {

    @NotBlank(message = "Place number is required")
    private String numeroPlace;

    private String range;
    private String typePlace;

    @NotBlank(message = "Room number is required")
    private String numeroSalle;

    public PlaceDTO() {}

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }

    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
}
