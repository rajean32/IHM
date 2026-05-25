package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;

import java.time.LocalDate;
import java.time.LocalTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EvenementDTO {

    private Integer idEvenement;

    @NotBlank(message = "Title is required")
    private String titre;

    private String description;

    @Future(message = "Event date must be in the future")
    private LocalDate dateEvenement;

    private LocalTime heureEvenement;
    private String image;
    private String statut;
    private String codeCategorie;
    private Integer idLieu;

    @NotBlank(message = "Organizer code is required")
    private String codeOrganisateur;

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
}
