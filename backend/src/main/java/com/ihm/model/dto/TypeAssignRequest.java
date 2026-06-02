package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.List;

public class TypeAssignRequest {
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
