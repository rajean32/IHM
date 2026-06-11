package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class CategorieDTO {
    @NotBlank private String codeCategorie;
    @NotBlank private String nomCategorie;
    private String description;
    private LocalDateTime dateCreation;
    private List<CaracteristiqueDTO> caracteristiques;
    private List<String> salleTypeCodes;
    private String specificConfig;

    public CategorieDTO() {}

    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
    public String getNomCategorie() { return nomCategorie; }
    public void setNomCategorie(String nomCategorie) { this.nomCategorie = nomCategorie; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
    public List<CaracteristiqueDTO> getCaracteristiques() { return caracteristiques; }
    public void setCaracteristiques(List<CaracteristiqueDTO> caracteristiques) { this.caracteristiques = caracteristiques; }
    public List<String> getSalleTypeCodes() { return salleTypeCodes; }
    public void setSalleTypeCodes(List<String> salleTypeCodes) { this.salleTypeCodes = salleTypeCodes; }
    public String getSpecificConfig() { return specificConfig; }
    public void setSpecificConfig(String specificConfig) { this.specificConfig = specificConfig; }
}
