package com.ihm.schemat;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDate;

@Entity
@Table(name = "UTILISATEUR")
@Inheritance(strategy = InheritanceType.JOINED)
public class Utilisateur {

    @Id
    @Column(name = "CodeUtilisateur", length = 50)
    @NotBlank(message = "User code is required")
    private String codeUtilisateur;

    @Column(name = "Nom", length = 100, nullable = false)
    @NotBlank(message = "Last name is required")
    private String nom;

    @Column(name = "Prenoms", length = 150, nullable = false)
    @NotBlank(message = "First names are required")
    private String prenoms;

    @Column(name = "Sexe", length = 1, nullable = false)
    @NotNull(message = "Sex is required")
    @Pattern(regexp = "^[MF]$", message = "Sexe must be M or F")
    private String sexe;

    @Column(name = "DateDeNaissance", nullable = false)
    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateDeNaissance;

    @Column(name = "E_mail", length = 100, nullable = false, unique = true)
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @Column(name = "Tel", length = 20, nullable = false)
    @NotBlank(message = "Phone number is required")
    private String tel;

    @Column(name = "MotDePasse", length = 255, nullable = false)
    @NotBlank(message = "Password is required")
    private String motDePasse;

    @Column(name = "PremiereConnexion", nullable = false)
    private boolean premiereConnexion = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeAdministrateur", referencedColumnName = "CodeAdministrateur")
    private Administrateur administrateur;

    public Utilisateur() {}

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

    public boolean isPremiereConnexion() { return premiereConnexion; }
    public void setPremiereConnexion(boolean premiereConnexion) { this.premiereConnexion = premiereConnexion; }

    public Administrateur getAdministrateur() { return administrateur; }
    public void setAdministrateur(Administrateur administrateur) { this.administrateur = administrateur; }
}
