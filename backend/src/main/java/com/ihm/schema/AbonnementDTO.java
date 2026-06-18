package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class AbonnementDTO {

    private Long idAbonnement;
    private String codeClient;
    private String codeOrganisateur;
    private LocalDateTime dateAbonnement;

    public AbonnementDTO() {}

    public Long getIdAbonnement() { return idAbonnement; }
    public void setIdAbonnement(Long idAbonnement) { this.idAbonnement = idAbonnement; }
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public String getCodeOrganisateur() { return codeOrganisateur; }
    public void setCodeOrganisateur(String codeOrganisateur) { this.codeOrganisateur = codeOrganisateur; }
    public LocalDateTime getDateAbonnement() { return dateAbonnement; }
    public void setDateAbonnement(LocalDateTime dateAbonnement) { this.dateAbonnement = dateAbonnement; }
}
