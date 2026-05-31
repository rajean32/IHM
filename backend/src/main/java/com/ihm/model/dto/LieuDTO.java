package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class LieuDTO {

    private Integer idLieu;

    @NotBlank(message = "Location name is required")
    private String nomLieu;

    private String adresse;
    private String ville;

    private List<SalleDTO> salles;

    public LieuDTO() {}

    public Integer getIdLieu() { return idLieu; }
    public void setIdLieu(Integer idLieu) { this.idLieu = idLieu; }

    public String getNomLieu() { return nomLieu; }
    public void setNomLieu(String nomLieu) { this.nomLieu = nomLieu; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }

    public List<SalleDTO> getSalles() { return salles; }
    public void setSalles(List<SalleDTO> salles) { this.salles = salles; }
}
