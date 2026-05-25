package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;

public class FirstLoginUpdateRequest {

    @NotBlank(message = "User code is required")
    private String codeUtilisateur;

    private String newPassword;
    private String newEmail;

    public FirstLoginUpdateRequest() {}

    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }

    public String getNewEmail() { return newEmail; }
    public void setNewEmail(String newEmail) { this.newEmail = newEmail; }
}
