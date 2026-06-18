package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ANNONCE")
public class Annonce {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idAnnonce")
    private Long idAnnonce;

    @Column(name = "idEvenement", nullable = false)
    private Integer idEvenement;

    @Column(name = "titre", length = 200, nullable = false)
    private String titre;

    @Column(name = "message", columnDefinition = "TEXT", nullable = false)
    private String message;

    @Column(name = "codeOrganisateur", length = 50, nullable = false)
    private String codeOrganisateur;

    @Column(name = "dateCreation", nullable = false)
    private LocalDateTime dateCreation;

    public Annonce() {}

    public Annonce(Integer idEvenement, String titre, String message, String codeOrganisateur) {
        this.idEvenement = idEvenement;
        this.titre = titre;
        this.message = message;
        this.codeOrganisateur = codeOrganisateur;
        this.dateCreation = LocalDateTime.now();
    }

    public Long getIdAnnonce() { return idAnnonce; }
    public void setIdAnnonce(Long idAnnonce) { this.idAnnonce = idAnnonce; }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
}
