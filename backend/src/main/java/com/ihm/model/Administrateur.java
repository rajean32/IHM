package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;
@Entity
@Table(name = "ADMINISTRATEUR")
public class Administrateur {
    @Id
    @Column(name = "CodeAdministrateur", length = 50)
    @NotBlank(message = "Code administrateur is required")
    private String codeAdministrateur;
    @Column(name = "MotdepasseAdministrateur", length = 255, nullable = false)
    @NotBlank(message = "Password is required")
    private String motdepasseAdministrateur;
    @OneToMany(mappedBy = "administrateur", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Utilisateur> utilisateurs = new ArrayList<>();
    public Administrateur() {}
    public Administrateur(String codeAdministrateur, String motdepasseAdministrateur) {
        this.codeAdministrateur = codeAdministrateur;
        this.motdepasseAdministrateur = motdepasseAdministrateur;
    }
    public String getCodeAdministrateur() { return codeAdministrateur; }
    public void setCodeAdministrateur(String codeAdministrateur) { this.codeAdministrateur = codeAdministrateur; }
    public String getMotdepasseAdministrateur() { return motdepasseAdministrateur; }
    public void setMotdepasseAdministrateur(String motdepasseAdministrateur) { this.motdepasseAdministrateur = motdepasseAdministrateur; }
    public List<Utilisateur> getUtilisateurs() { return utilisateurs; }
    public void setUtilisateurs(List<Utilisateur> utilisateurs) { this.utilisateurs = utilisateurs; }
}
