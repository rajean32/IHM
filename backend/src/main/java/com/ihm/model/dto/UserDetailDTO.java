package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDate;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserDetailDTO {

    private String codeUtilisateur;
    private String nom;
    private String prenoms;
    private String sexe;
    private LocalDate dateDeNaissance;
    private String email;
    private String tel;
    private boolean premiereConnexion;
    private boolean actif;
    private String role;
    private String codeAdministrateur;

    public UserDetailDTO() {}

    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }

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

    public boolean isPremiereConnexion() { return premiereConnexion; }
    public void setPremiereConnexion(boolean premiereConnexion) { this.premiereConnexion = premiereConnexion; }

    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getCodeAdministrateur() { return codeAdministrateur; }
    public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }
}
