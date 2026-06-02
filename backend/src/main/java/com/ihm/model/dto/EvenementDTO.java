package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.time.LocalTime;

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
    private Integer idLieu;

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

    public Integer getIdLieu() { return idLieu; }
    public void setIdLieu(Integer idLieu) { this.idLieu = idLieu; }

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
}
