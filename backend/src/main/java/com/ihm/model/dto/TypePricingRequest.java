package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

public class TypePricingRequest {
    @NotBlank
    private String typePlace;
    private BigDecimal prix;

    public TypePricingRequest() {}

    public String getTypePlace() { return typePlace; }
    public void setTypePlace(String typePlace) { this.typePlace = typePlace; }

    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
}
