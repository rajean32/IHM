package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class SalleDTO {

    @NotBlank(message = "Room number is required")
    private String numeroSalle;

    @NotBlank(message = "Room name is required")
    private String nomSalle;

    private Integer idLieu;

    public SalleDTO() {}

    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }

    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }

    public Integer getIdLieu() { return idLieu; }
    public void setIdLieu(Integer idLieu) { this.idLieu = idLieu; }
}
