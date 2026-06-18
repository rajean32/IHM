package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "AVIS")
public class Avis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idAvis")
    private Long idAvis;

    @Column(name = "idEvenement", nullable = false)
    private Integer idEvenement;

    @Column(name = "codeClient", length = 50, nullable = false)
    private String codeClient;

    @Column(name = "note", nullable = false)
    private Integer note;

    @Column(name = "commentaire", columnDefinition = "TEXT")
    private String commentaire;

    @Column(name = "dateCreation", nullable = false)
    private LocalDateTime dateCreation;

    public Avis() {}

    public Avis(Integer idEvenement, String codeClient, Integer note, String commentaire) {
        this.idEvenement = idEvenement;
        this.codeClient = codeClient;
        this.note = note;
        this.commentaire = commentaire;
        this.dateCreation = LocalDateTime.now();
    }

    public Long getIdAvis() { return idAvis; }
    public void setIdAvis(Long idAvis) { this.idAvis = idAvis; }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public Integer getNote() { return note; }
    public void setNote(Integer note) { this.note = note; }
    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
}
