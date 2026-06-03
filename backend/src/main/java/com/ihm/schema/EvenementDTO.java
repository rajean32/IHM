package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EvenementDTO {

    private Integer idEvenement;
    @NotBlank(message = "Title is required")
    private String titre;
    private String description;
    @NotNull(message = "Event date is required")
    @Future(message = "Event date must be in the future")
    private LocalDate dateEvenement;
    private LocalTime heureEvenement;
    private String image;
    private String statut;
    private String codeCategorie;
    private String codeLieu;
    @NotBlank(message = "Organizer code is required")
    private String codeOrganisateur;
    private String motifAnnulation;
    private String organisateurNom;
    private String lieuNom;
    private String categorieNom;
    private Long placesTotal;
    private Long placesDisponibles;

    public EvenementDTO() {}

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
    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
    public String getCodeLieu() { return codeLieu; }
    public void setCodeLieu(String codeLieu) { this.codeLieu = codeLieu; }
    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
    public String getMotifAnnulation() { return motifAnnulation; }
    public void setMotifAnnulation(String motifAnnulation) { this.motifAnnulation = motifAnnulation; }
    public String getOrganisateurNom() { return organisateurNom; }
    public void setOrganisateurNom(String organisateurNom) { this.organisateurNom = organisateurNom; }
    public String getLieuNom() { return lieuNom; }
    public void setLieuNom(String lieuNom) { this.lieuNom = lieuNom; }
    public String getCategorieNom() { return categorieNom; }
    public void setCategorieNom(String categorieNom) { this.categorieNom = categorieNom; }
    public Long getPlacesTotal() { return placesTotal; }
    public void setPlacesTotal(Long placesTotal) { this.placesTotal = placesTotal; }
    public Long getPlacesDisponibles() { return placesDisponibles; }
    public void setPlacesDisponibles(Long placesDisponibles) { this.placesDisponibles = placesDisponibles; }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class EventDetail {
        private Integer idEvenement;
        private String titre;
        private String description;
        private LocalDate dateEvenement;
        private LocalTime heureEvenement;
        private String image;
        private String statut;
        private String codeCategorie;
        private String categorieNom;
        private String codeLieu;
        private String lieuNom;
        private String lieuAdresse;
        private String lieuVille;
        private String codeOrganisateur;
        private String organisateurNom;
        private long placesDisponibles;
        private long placesTotal;
        private BigDecimal prixMin;
        private BigDecimal prixMax;
        private List<com.ihm.schema.SalleDTO.SeatingDTO> places;

        public EventDetail() {}

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
        public String getCodeCategorie() { return codeCategorie; }
        public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
        public String getCategorieNom() { return categorieNom; }
        public void setCategorieNom(String categorieNom) { this.categorieNom = categorieNom; }
        public String getCodeLieu() { return codeLieu; }
        public void setCodeLieu(String codeLieu) { this.codeLieu = codeLieu; }
        public String getLieuNom() { return lieuNom; }
        public void setLieuNom(String lieuNom) { this.lieuNom = lieuNom; }
        public String getLieuAdresse() { return lieuAdresse; }
        public void setLieuAdresse(String lieuAdresse) { this.lieuAdresse = lieuAdresse; }
        public String getLieuVille() { return lieuVille; }
        public void setLieuVille(String lieuVille) { this.lieuVille = lieuVille; }
        public String getCodeOrganisateur() { return codeOrganisateur; }
        public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
        public String getOrganisateurNom() { return organisateurNom; }
        public void setOrganisateurNom(String organisateurNom) { this.organisateurNom = organisateurNom; }
        public long getPlacesDisponibles() { return placesDisponibles; }
        public void setPlacesDisponibles(long placesDisponibles) { this.placesDisponibles = placesDisponibles; }
        public long getPlacesTotal() { return placesTotal; }
        public void setPlacesTotal(long placesTotal) { this.placesTotal = placesTotal; }
        public BigDecimal getPrixMin() { return prixMin; }
        public void setPrixMin(BigDecimal prixMin) { this.prixMin = prixMin; }
        public BigDecimal getPrixMax() { return prixMax; }
        public void setPrixMax(BigDecimal prixMax) { this.prixMax = prixMax; }
        public List<com.ihm.schema.SalleDTO.SeatingDTO> getPlaces() { return places; }
        public void setPlaces(List<com.ihm.schema.SalleDTO.SeatingDTO> places) { this.places = places; }
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class EventSearchRequest {
        private String q;
        private String categorie;
        private String ville;
        private String codeLieu;
        private LocalDate dateFrom;
        private LocalDate dateTo;
        private String statut;
        private BigDecimal prixMin;
        private BigDecimal prixMax;

        public EventSearchRequest() {}

        public String getQ() { return q; }
        public void setQ(String q) { this.q = q; }
        public String getCategorie() { return categorie; }
        public void setCategorie(String categorie) { this.categorie = categorie; }
        public String getVille() { return ville; }
        public void setVille(String ville) { this.ville = ville; }
        public String getCodeLieu() { return codeLieu; }
        public void setCodeLieu(String codeLieu) { this.codeLieu = codeLieu; }
        public LocalDate getDateFrom() { return dateFrom; }
        public void setDateFrom(LocalDate dateFrom) { this.dateFrom = dateFrom; }
        public LocalDate getDateTo() { return dateTo; }
        public void setDateTo(LocalDate dateTo) { this.dateTo = dateTo; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
        public BigDecimal getPrixMin() { return prixMin; }
        public void setPrixMin(BigDecimal prixMin) { this.prixMin = prixMin; }
        public BigDecimal getPrixMax() { return prixMax; }
        public void setPrixMax(BigDecimal prixMax) { this.prixMax = prixMax; }
    }

    public static class CancelEventRequest {
        @NotBlank(message = "Cancellation reason is required")
        private String motif;

        public CancelEventRequest() {}

        public String getMotif() { return motif; }
        public void setMotif(String motif) { this.motif = motif; }
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class EventPlaceConfig {
        private String numeroPlace;
        private String range;
        private String typePlace;
        private BigDecimal prix;
        private String statut;
        private String numeroSalle;
        private String nomSalle;
        private String typePlaceOverride;
        private BigDecimal prixOverride;
        private String statutPlace;

        public EventPlaceConfig() {}

        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
        public String getRange() { return range; }
        public void setRange(String range) { this.range = range; }
        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
        public String getNumeroSalle() { return numeroSalle; }
        public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
        public String getNomSalle() { return nomSalle; }
        public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }
        public String getTypePlaceOverride() { return typePlaceOverride; }
        public void setTypePlaceOverride(String typePlaceOverride) { this.typePlaceOverride = typePlaceOverride; }
        public BigDecimal getPrixOverride() { return prixOverride; }
        public void setPrixOverride(BigDecimal prixOverride) { this.prixOverride = prixOverride; }
        public String getStatutPlace() { return statutPlace; }
        public void setStatutPlace(String statutPlace) { this.statutPlace = statutPlace; }
    }
}
