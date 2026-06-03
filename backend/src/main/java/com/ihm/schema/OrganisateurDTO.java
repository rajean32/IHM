package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class OrganisateurDTO {
    private String codeOrganisateur;
    @NotBlank(message = "Last name is required")
    private String nom;
    @NotBlank(message = "First names are required")
    private String prenoms;
    @Pattern(regexp = "^[MF]$", message = "Sex must be M or F")
    private String sexe;
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateDeNaissance;
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    @NotBlank(message = "Phone number is required")
    private String tel;
    private String codeAdministrateur;
    public OrganisateurDTO() {}
    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
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
    public String getCodeAdministrateur() { return codeAdministrateur; }
    public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }
}
