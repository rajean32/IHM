package com.ihm.schema;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;

public class AuthDTO {
    private AuthDTO() {}

    public static class LoginRequest {
        @NotBlank private String email;
        @NotBlank private String motDePasse;
        public LoginRequest() {}
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getMotDePasse() { return motDePasse; }
        public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }
    }

    public static class LoginResponse {
        private String token;
        private String codeUtilisateur;
        private String email;
        private String nom;
        private String prenoms;
        private String role;
        private boolean isFirstLogin;
        public LoginResponse() {}
        public LoginResponse(String token, String codeUtilisateur, String email, String nom, String prenoms, String role) {
            this.token = token; this.codeUtilisateur = codeUtilisateur; this.email = email;
            this.nom = nom; this.prenoms = prenoms; this.role = role;
        }
        public LoginResponse(String token, String codeUtilisateur, String email, String nom, String prenoms, String role, boolean isFirstLogin) {
            this(token, codeUtilisateur, email, nom, prenoms, role); this.isFirstLogin = isFirstLogin;
        }
        public String getToken() { return token; }
        public void setToken(String token) { this.token = token; }
        public String getCodeUtilisateur() { return codeUtilisateur; }
        public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getPrenoms() { return prenoms; }
        public void setPrenoms(String prenoms) { this.prenoms = prenoms; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        public boolean isFirstLogin() { return isFirstLogin; }
        public void setFirstLogin(boolean isFirstLogin) { this.isFirstLogin = isFirstLogin; }
    }

    public static class RegisterRequest {
        @NotBlank private String nom;
        @NotBlank private String prenoms;
        @NotNull @Pattern(regexp = "^[MF]$") private String sexe;
        @NotNull @Past private LocalDate dateDeNaissance;
        @NotBlank @Email private String email;
        @NotBlank private String tel;
        @NotBlank private String motDePasse;
        private String codeUtilisateur;
        private String type;
        public RegisterRequest() {}
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getPrenoms() { return prenoms; }
        public void setPrenoms(String prenoms) { this.prenoms = prenoms; }
        public String getSexe() { return sexe; }
        public void setSexe(String sexe) { this.sexe = sexe; }
        public LocalDate getDateDeNaissance() { return dateDeNaissance; }
        public void setDateDeNaissance(LocalDate dateDeNaissance) { this.dateDeNaissance = dateDeNaissance; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getTel() { return tel; }
        public void setTel(String tel) { this.tel = tel; }
        public String getMotDePasse() { return motDePasse; }
        public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }
        public String getCodeUtilisateur() { return codeUtilisateur; }
        public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
    }

    public static class FirstLoginUpdateRequest {
        @NotBlank private String codeUtilisateur;
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
}
