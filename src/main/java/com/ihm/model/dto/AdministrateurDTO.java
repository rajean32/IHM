package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AdministrateurDTO {

    private String codeAdministrateur;

    @NotBlank(message = "Password is required")
    private String motdepasseAdministrateur;

    public AdministrateurDTO() {}

    public String getCodeAdministrateur() { return codeAdministrateur; }
    public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }

    public String getMotdepasseAdministrateur() { return motdepasseAdministrateur; }
    public void setMotdepasseAdministrateur(String motdepasseAdministrateur) { this.motdepasseAdministrateur = motdepasseAdministrateur; }
}
