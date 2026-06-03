package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LieuDTO {
    private String code;
    @NotBlank(message = "Location name is required")
    private String nomLieu;
    private String adresse;
    private String ville;
    private List<com.ihm.schema.SalleDTO> salles;
    public LieuDTO() {}
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getNomLieu() { return nomLieu; }
    public void setNomLieu(String nomLieu) { this.nomLieu = nomLieu; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }
    public List<com.ihm.schema.SalleDTO> getSalles() { return salles; }
    public void setSalles(List<com.ihm.schema.SalleDTO> salles) { this.salles = salles; }
}
