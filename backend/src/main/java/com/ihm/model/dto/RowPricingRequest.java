package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

public class RowPricingRequest {
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
