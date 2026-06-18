package com.ihm.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PREFERENCE_CLIENT")
public class PreferenceClient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idPreference")
    private Long idPreference;

    @Column(name = "codeClient", length = 50, nullable = false)
    private String codeClient;

    @Column(name = "codeCategorie", length = 50, nullable = false)
    private String codeCategorie;

    public PreferenceClient() {}

    public PreferenceClient(String codeClient, String codeCategorie) {
        this.codeClient = codeClient;
        this.codeCategorie = codeCategorie;
    }

    public Long getIdPreference() { return idPreference; }
    public void setIdPreference(Long idPreference) { this.idPreference = idPreference; }
    public String getCodeClient() { return codeClient; }
    public void setCodeClient(String codeClient) { this.codeClient = codeClient; }
    public String getCodeCategorie() { return codeCategorie; }
    public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }
}
