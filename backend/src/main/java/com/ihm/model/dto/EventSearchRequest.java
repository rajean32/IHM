package com.ihm.model.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDate;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class EventSearchRequest {

    private String q;
    private String categorie;
    private String ville;
    private LocalDate dateFrom;
    private LocalDate dateTo;
    private String statut;

    public EventSearchRequest() {}

    public String getQ() { return q; }
    public void setQ(String q) { this.q = q; }

    public String getCategorie() { return categorie; }
    public void setCategorie(String categorie) { this.categorie = categorie; }

    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }

    public LocalDate getDateFrom() { return dateFrom; }
    public void setDateFrom(LocalDate dateFrom) { this.dateFrom = dateFrom; }

    public LocalDate getDateTo() { return dateTo; }
    public void setDateTo(LocalDate dateTo) { this.dateTo = dateTo; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
}
