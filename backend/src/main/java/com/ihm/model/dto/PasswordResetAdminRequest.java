package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;

public class PasswordResetAdminRequest {

    @NotBlank(message = "User code is required")
    private String codeUtilisateur;

    @NotBlank(message = "New password is required")
    private String newPassword;

    public PasswordResetAdminRequest() {}

    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
