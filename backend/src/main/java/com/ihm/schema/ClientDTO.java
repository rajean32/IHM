package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ClientDTO {
    private String codeClient;
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
    public ClientDTO() {}
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
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
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ClientTicket {
        private String codeTicket;
        private BigDecimal prix;
        private String evenementTitre;
        private LocalDate dateEvenement;
        private LocalTime heureEvenement;
        private String lieuNom;
        private String salleNom;
        private String numeroPlace;
        private String rang;
        private String typePlace;
        private String statut;
        public ClientTicket() {}
        public String getCodeTicket() { return codeTicket; }
        public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
        public String getEvenementTitre() { return evenementTitre; }
        public void setEvenementTitre(String evenementTitre) { this.evenementTitre = evenementTitre; }
        public LocalDate getDateEvenement() { return dateEvenement; }
        public void setDateEvenement(LocalDate dateEvenement) { this.dateEvenement = dateEvenement; }
        public LocalTime getHeureEvenement() { return heureEvenement; }
        public void setHeureEvenement(LocalTime heureEvenement) { this.heureEvenement = heureEvenement; }
        public String getLieuNom() { return lieuNom; }
        public void setLieuNom(String lieuNom) { this.lieuNom = lieuNom; }
        public String getSalleNom() { return salleNom; }
        public void setSalleNom(String salleNom) { this.salleNom = salleNom; }
        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
        public String getRang() { return rang; }
        public void setRang(String rang) { this.rang = rang; }
        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
    }
}
