package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SalleDTO {
    @NotBlank(message = "Room number is required")
    private String numeroSalle;
    @NotBlank(message = "Room name is required")
    private String nomSalle;
    private String codeLieu;
    public SalleDTO() {}
    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
    public String getNomSalle() { return nomSalle; }
    public void setNomSalle(String nomSalle) { this.nomSalle = nomSalle; }
    public String getCodeLieu() { return codeLieu; }
    public void setCodeLieu(String codeLieu) { this.codeLieu = codeLieu; }
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class SeatingDTO {
        private String numeroPlace;
        private String rang;
        private String typePlace;
        private boolean disponible;
        private BigDecimal prix;
        private String salle;
        private String statut;
        public SeatingDTO() {}
        public String getNumeroPlace() { return numeroPlace; }
        public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
        public String getRang() { return rang; }
        public void setRang(String rang) { this.rang = rang; }
        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public boolean isDisponible() { return disponible; }
        public void setDisponible(boolean disponible) { this.disponible = disponible; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
        public String getSalle() { return salle; }
        public void setSalle(String salle) { this.salle = salle; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
    }
}
