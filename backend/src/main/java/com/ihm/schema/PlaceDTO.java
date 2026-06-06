package com.ihm.schema;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PlaceDTO {

    @NotBlank(message = "Place number is required")
    private String numeroPlace;
    private String range;
    @NotBlank(message = "Room number is required")
    private String numeroSalle;

    public PlaceDTO() {}

    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
    public String getRange() { return range; }
    public void setRange(String range) { this.range = range; }
    public String getNumeroSalle() { return numeroSalle; }
    public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class BatchPlaceRequest {
        @NotBlank(message = "Room number is required")
        private String numeroSalle;
        @Min(value = 1, message = "Number of rows must be >= 1")
        private int nombreRangees;
        @Min(value = 1, message = "Number of seats per row must be >= 1")
        private int placesParRangee;
        private String prefixeRangee = "";
        private String typePlace;
        private BigDecimal prix;
        private int debutNumero = 1;

        public BatchPlaceRequest() {}

        public String getNumeroSalle() { return numeroSalle; }
        public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
        public int getNombreRangees() { return nombreRangees; }
        public void setNombreRangees(int nombreRangees) { this.nombreRangees = nombreRangees; }
        public int getPlacesParRangee() { return placesParRangee; }
        public void setPlacesParRangee(int placesParRangee) { this.placesParRangee = placesParRangee; }
        public String getPrefixeRangee() { return prefixeRangee; }
        public void setPrefixeRangee(String prefixeRangee) { this.prefixeRangee = prefixeRangee; }
        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
        public int getDebutNumero() { return debutNumero; }
        public void setDebutNumero(int debutNumero) { this.debutNumero = debutNumero; }
    }

    public static class RowPricingRequest {
        @NotBlank
        private String rang;
        @NotBlank
        private String typePlace;
        private BigDecimal prix;

        public RowPricingRequest() {}

        public String getRang() { return rang; }
        public void setRang(String rang) { this.rang = rang; }
        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
    }

    public static class TypePricingRequest {
        @NotBlank
        private String typePlace;
        private BigDecimal prix;

        public TypePricingRequest() {}

        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public BigDecimal getPrix() { return prix; }
        public void setPrix(BigDecimal prix) { this.prix = prix; }
    }

    public static class TypeAssignRequest {
        @NotBlank
        private String typePlace;
        private List<String> placeIds;
        private List<String> rows;

        public TypeAssignRequest() {}

        public String getTypePlace() { return typePlace; }
        public void setTypePlace(String typePlace) { this.typePlace = typePlace; }
        public List<String> getPlaceIds() { return placeIds; }
        public void setPlaceIds(List<String> placeIds) { this.placeIds = placeIds; }
        public List<String> getRows() { return rows; }
        public void setRows(List<String> rows) { this.rows = rows; }
    }
}
