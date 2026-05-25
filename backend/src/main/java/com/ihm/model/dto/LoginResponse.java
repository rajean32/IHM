package com.ihm.model.dto;

public class LoginResponse {

    private String token;
    private String codeUtilisateur;
    private String email;
    private String role;
    private boolean isFirstLogin;

    public LoginResponse() {}

    public LoginResponse(String token, String codeUtilisateur, String email, String role) {
        this.token = token;
        this.codeUtilisateur = codeUtilisateur;
        this.email = email;
        this.role = role;
        this.isFirstLogin = false;
    }

    public LoginResponse(String token, String codeUtilisateur, String email, String role, boolean isFirstLogin) {
        this.token = token;
        this.codeUtilisateur = codeUtilisateur;
        this.email = email;
        this.role = role;
        this.isFirstLogin = isFirstLogin;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isFirstLogin() { return isFirstLogin; }
    public void setFirstLogin(boolean isFirstLogin) { this.isFirstLogin = isFirstLogin; }
}
