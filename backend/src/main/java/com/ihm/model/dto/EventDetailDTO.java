package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EventDetailDTO {

    private Integer idEvenement;
    private String titre;
    private String description;
    private LocalDate dateEvenement;
    private LocalTime heureEvenement;
    private String image;
    private String statut;
    private String codeCategorie;
    private String categorieNom;
    private Integer idLieu;
    private String lieuNom;
    private String lieuAdresse;
    private String lieuVille;
    private String codeOrganisateur;
    private String organisateurNom;
    private long placesDisponibles;
    private long placesTotal;
    private BigDecimal prixMin;
    private BigDecimal prixMax;
    private List<SeatingDTO> places;

    public EventDetailDTO() {}

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

    public Integer getIdLieu() { return idLieu; }
    public void setIdLieu(Integer idLieu) { this.idLieu = idLieu; }

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

    public List<SeatingDTO> getPlaces() { return places; }
    public void setPlaces(List<SeatingDTO> places) { this.places = places; }
}
