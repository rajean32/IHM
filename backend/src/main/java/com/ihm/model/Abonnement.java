package com.ihm.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ABONNEMENT")
public class Abonnement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idAbonnement")
    private Long idAbonnement;

    @Column(name = "codeClient", length = 50, nullable = false)
    private String codeClient;

    @Column(name = "codeOrganisateur", length = 50, nullable = false)
    private String codeOrganisateur;

    @Column(name = "dateAbonnement", nullable = false)
    private LocalDateTime dateAbonnement;

    public Abonnement() {}

    public Abonnement(String codeClient, String codeOrganisateur) {
        this.codeClient = codeClient;
        this.codeOrganisateur = codeOrganisateur;
        this.dateAbonnement = LocalDateTime.now();
    }

    public Long getIdAbonnement() { return idAbonnement; }
    public void setIdAbonnement(Long idAbonnement) { this.idAbonnement = idAbonnement; }
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
    public LocalDateTime getDateAbonnement() { return dateAbonnement; }
    public void setDateAbonnement(LocalDateTime dateAbonnement) { this.dateAbonnement = dateAbonnement; }
}
