package com.ihm.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PREFERENCE_NOTIFICATION")
public class PreferenceNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idPref")
    private Long idPref;

    @Column(name = "codeUtilisateur", length = 50, nullable = false)
    private String codeUtilisateur;

    @Column(name = "typeNotification", length = 50, nullable = false)
    private String typeNotification;

    @Column(name = "canal", length = 20, nullable = false)
    private String canal;

    @Column(name = "actif", nullable = false)
    private boolean actif = true;

    public PreferenceNotification() {}

    public PreferenceNotification(String codeUtilisateur, String typeNotification, String canal) {
        this.codeUtilisateur = codeUtilisateur;
        this.typeNotification = typeNotification;
        this.canal = canal;
        this.actif = true;
    }

    public Long getIdPref() { return idPref; }
    public void setIdPref(Long idPref) { this.idPref = idPref; }
    public String getCodeUtilisateur() { return codeUtilisateur; }
    public void setCodeUtilisateur(String codeUtilisateur) { this.codeUtilisateur = codeUtilisateur; }
    public String getTypeNotification() { return typeNotification; }
    public void setTypeNotification(String typeNotification) { this.typeNotification = typeNotification; }
    public String getCanal() { return canal; }
    public void setCanal(String canal) { this.canal = canal; }
    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
}
