package com.ihm.model.dto;

import jakarta.validation.constraints.NotBlank;

public class CancelEventRequest {

    @NotBlank(message = "Cancellation reason is required")
    private String motif;

    public CancelEventRequest() {}

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }
}
