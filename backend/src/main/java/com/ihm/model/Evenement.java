package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
@Entity
@Table(name = "EVENEMENT")
public class Evenement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idEvenement")
    private Integer idEvenement;
    @Column(name = "titre", length = 150, nullable = false)
    @NotBlank(message = "Title is required")
    private String titre;
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    @Column(name = "dateEvenement", nullable = false)
    private LocalDate dateEvenement;
    @Column(name = "heureEvenement")
    private LocalTime heureEvenement;
    @Column(name = "image", length = 255)
    private String image;
    @Column(name = "statut", length = 50)
    private String statut;
    @Column(name = "motifAnnulation", columnDefinition = "TEXT")
    private String motifAnnulation;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeCategorie", referencedColumnName = "CodeCategorie")
    private Categorie categorie;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "codeLieu", referencedColumnName = "code")
    private Lieu lieu;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeOrganisateur", referencedColumnName = "CodeOrganisateur", nullable = false)
    private Organisateur organisateur;
    @OneToMany(mappedBy = "evenement", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Concerner> concerners = new ArrayList<>();
    public Evenement() {}
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDate getDateEvenement() { return dateEvenement; }
    public void setDateEvenement(LocalDate dateEvenement) { this.dateEvenement = dateEvenement; }
    public LocalTime getHeureEvenement() { return heureEvenement; }
    public void setHeureEvenement(LocalTime heureEvenement) { this.heureEvenement = heureEvenement; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public String getMotifAnnulation() { return motifAnnulation; }
    public void setMotifAnnulation(String motifAnnulation) { this.motifAnnulation = motifAnnulation; }
    public Categorie getCategorie() { return categorie; }
    public void setCategorie(Categorie categorie) { this.categorie = categorie; }
    public Lieu getLieu() { return lieu; }
    public void setLieu(Lieu lieu) { this.lieu = lieu; }
    public Organisateur getOrganisateur() { return organisateur; }
    public void setOrganisateur(Organisateur organisateur) { this.organisateur = organisateur; }
    public List<Concerner> getConcerners() { return concerners; }
    public void setConcerners(List<Concerner> concerners) { this.concerners = concerners; }
}
