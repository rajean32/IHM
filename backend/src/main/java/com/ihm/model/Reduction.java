package com.ihm.model;

import com.ihm.model.enums.ModeReduction;
import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "REDUCTION")
public class Reduction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "idReduction")
    private Long idReduction;

    @Column(name = "code", length = 50, unique = true)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode", nullable = false)
    private ModeReduction mode;

    @Column(name = "tauxReduction", precision = 5, scale = 2)
    @DecimalMin(value = "0.0", inclusive = true)
    @DecimalMax(value = "100.0", inclusive = true)
    private BigDecimal tauxReduction;

    @Column(name = "valeurFixe", precision = 10, scale = 2)
    private BigDecimal valeurFixe;

    @Column(name = "dateDebut")
    private LocalDateTime dateDebut;

    @Column(name = "dateFin")
    private LocalDateTime dateFin;

    @Column(name = "utilisationMax")
    private Integer utilisationMax;

    @Column(name = "utilisationCount")
    private Integer utilisationCount = 0;

    @Column(name = "actif")
    private boolean actif = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "idEvenement")
    private Evenement evenement;

    public Reduction() {}

    // Getters et Setters
    public Long getIdReduction() { return idReduction; }
    public void setIdReduction(Long idReduction) { this.idReduction = idReduction; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public ModeReduction getMode() { return mode; }
    public void setMode(ModeReduction mode) { this.mode = mode; }

    public BigDecimal getTauxReduction() { return tauxReduction; }
    public void setTauxReduction(BigDecimal tauxReduction) { this.tauxReduction = tauxReduction; }

    public BigDecimal getValeurFixe() { return valeurFixe; }
    public void setValeurFixe(BigDecimal valeurFixe) { this.valeurFixe = valeurFixe; }

    public LocalDateTime getDateDebut() { return dateDebut; }
    public void setDateDebut(LocalDateTime dateDebut) { this.dateDebut = dateDebut; }

    public LocalDateTime getDateFin() { return dateFin; }
    public void setDateFin(LocalDateTime dateFin) { this.dateFin = dateFin; }

    public Integer getUtilisationMax() { return utilisationMax; }
    public void setUtilisationMax(Integer utilisationMax) { this.utilisationMax = utilisationMax; }

    public Integer getUtilisationCount() { return utilisationCount; }
    public void setUtilisationCount(Integer utilisationCount) { this.utilisationCount = utilisationCount; }

    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }

    public Evenement getEvenement() { return evenement; }
    public void setEvenement(Evenement evenement) { this.evenement = evenement; }
}