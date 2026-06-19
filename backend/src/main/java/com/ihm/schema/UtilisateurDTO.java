package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import java.util.List;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UtilisateurDTO {
    private String codeUtilisateur;
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
    private String motDePasse;
    public String getMotDePasse() { return motDePasse; }
    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }
    private String ville;
    private String villeCode;
    private String codeAdministrateur;
    private String photo;
    private String bio;
    private String siteWeb;
    private String reseauxSociaux;
    public UtilisateurDTO() {}
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
    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }
    public String getVilleCode() { return villeCode; }
    public void setVilleCode(String villeCode) { this.villeCode = villeCode; }
    public String getCodeAdministrateur() { return codeAdministrateur; }
    public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }
    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getSiteWeb() { return siteWeb; }
    public void setSiteWeb(String siteWeb) { this.siteWeb = siteWeb; }
    public String getReseauxSociaux() { return reseauxSociaux; }
    public void setReseauxSociaux(String reseauxSociaux) { this.reseauxSociaux = reseauxSociaux; }
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class AdministrateurDTO {
        private String codeAdministrateur;
        @NotBlank(message = "Password is required")
        private String motdepasseAdministrateur;
        public AdministrateurDTO() {}
        public String getCodeAdministrateur() { return codeAdministrateur; }
        public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }
        public String getMotdepasseAdministrateur() { return motdepasseAdministrateur; }
        public void setMotdepasseAdministrateur(String motdepasseAdministrateur) { this.motdepasseAdministrateur = motdepasseAdministrateur; }
    }
    public static class UserCreateRequest {
        private String codeUtilisateur;
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
        private String motDePasse;
        @NotBlank(message = "Role is required")
        private String role;
        public UserCreateRequest() {}
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
        public String getMotDePasse() { return motDePasse; }
        public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }
    public static class UserDetail {
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
        public UserDetail() {}
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
    public static class UserUpdateRequest {
        private String nom;
        private String prenoms;
        private String sexe;
        @Past(message = "Date of birth must be in the past")
        private LocalDate dateDeNaissance;
        @Email(message = "Invalid email format")
        private String email;
        private String tel;
        private String motDePasse;
        private String role;
        public UserUpdateRequest() {}
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
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }

    public static class UserRoleUpdateRequest {
        private String role;
        public UserRoleUpdateRequest() {}
        public UserRoleUpdateRequest(String role) { this.role = role; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }
    public static class ConsistencyReport {
        private List<String> issues;
        private List<String> warnings;
        private long issueCount;
        private long warningCount;
        public ConsistencyReport(List<String> issues, List<String> warnings) {
            this.issues = issues;
            this.warnings = warnings;
            this.issueCount = issues.size();
            this.warningCount = warnings.size();
        }
        public List<String> getIssues() { return issues; }
        public List<String> getWarnings() { return warnings; }
        public long getIssueCount() { return issueCount; }
        public long getWarningCount() { return warningCount; }
    }
}
