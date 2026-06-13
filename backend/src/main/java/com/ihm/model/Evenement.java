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

    @Column(name = "dateFin")
    private LocalDate dateFin;

    @Column(name = "heureEvenement")
    private LocalTime heureEvenement;

    @Column(name = "prix", precision = 10, scale = 2)
    private BigDecimal prix;

    @Column(name = "capacite")
    private Integer capacite;

    @Column(name = "image", columnDefinition = "BYTEA")
    private byte[] image;

    @Column(name = "statut", length = 50)
    private String statut;

    @Column(name = "motifAnnulation", columnDefinition = "TEXT")
    private String motifAnnulation;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_agencement", length = 50)
    private TypeAgencement typeAgencement;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeCategorie", referencedColumnName = "CodeCategorie")
    private Categorie categorie;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "codeLieu", referencedColumnName = "code")
    private Lieu lieu;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "numeroSalle", referencedColumnName = "numeroSalle")
    private Salle salle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CodeOrganisateur", referencedColumnName = "CodeOrganisateur", nullable = false)
    private Organisateur organisateur;

    @OneToMany(mappedBy = "evenement", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Concerner> concerners = new ArrayList<>();

    @OneToMany(mappedBy = "evenement", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<EvenementCaracteristiqueValeur> caracteristiqueValeurs = new ArrayList<>();

    public Evenement() {}

    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDate getDateEvenement() { return dateEvenement; }
    public void setDateEvenement(LocalDate dateEvenement) { this.dateEvenement = dateEvenement; }
    public LocalDate getDateFin() { return dateFin; }
    public void setDateFin(LocalDate dateFin) { this.dateFin = dateFin; }
    public LocalTime getHeureEvenement() { return heureEvenement; }
    public void setHeureEvenement(LocalTime heureEvenement) { this.heureEvenement = heureEvenement; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public Integer getCapacite() { return capacite; }
    public void setCapacite(Integer capacite) { this.capacite = capacite; }
    public byte[] getImage() { return image; }
    public void setImage(byte[] image) { this.image = image; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public String getMotifAnnulation() { return motifAnnulation; }
    public void setMotifAnnulation(String motifAnnulation) { this.motifAnnulation = motifAnnulation; }
    public TypeAgencement getTypeAgencement() { return typeAgencement; }
    public void setTypeAgencement(TypeAgencement typeAgencement) { this.typeAgencement = typeAgencement; }
    public Categorie getCategorie() { return categorie; }
    public void setCategorie(Categorie categorie) { this.categorie = categorie; }
    public Lieu getLieu() { return lieu; }
    public void setLieu(Lieu lieu) { this.lieu = lieu; }
    public Salle getSalle() { return salle; }
    public void setSalle(Salle salle) { this.salle = salle; }
    public Organisateur getOrganisateur() { return organisateur; }
    public void setOrganisateur(Organisateur organisateur) { this.organisateur = organisateur; }
    public List<Concerner> getConcerners() { return concerners; }
    public void setConcerners(List<Concerner> concerners) { this.concerners = concerners; }
    public List<EvenementCaracteristiqueValeur> getCaracteristiqueValeurs() { return caracteristiqueValeurs; }
    public void setCaracteristiqueValeurs(List<EvenementCaracteristiqueValeur> caracteristiqueValeurs) { this.caracteristiqueValeurs = caracteristiqueValeurs; }
}
