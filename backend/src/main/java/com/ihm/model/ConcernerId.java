package com.ihm.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.Objects;
@Embeddable
public class ConcernerId implements Serializable {
    @Column(name = "idEvenement")
    private Integer idEvenement;
    @Column(name = "CodeTicket", length = 50)
    private String codeTicket;
    @Column(name = "NumeroPlace", length = 50)
    private String numeroPlace;
    public ConcernerId() {}
    public ConcernerId(Integer idEvenement, String codeTicket, String numeroPlace) {
        this.idEvenement = idEvenement;
        this.codeTicket = codeTicket;
        this.numeroPlace = numeroPlace;
    }
    public Integer getIdEvenement() { return idEvenement; }
    public void setIdEvenement(Integer idEvenement) { this.idEvenement = idEvenement; }
    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
    public String getNumeroPlace() { return numeroPlace; }
    public void setNumeroPlace(String numeroPlace) { this.numeroPlace = numeroPlace; }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ConcernerId that)) return false;
        return Objects.equals(idEvenement, that.idEvenement)
                && Objects.equals(codeTicket, that.codeTicket)
                && Objects.equals(numeroPlace, that.numeroPlace);
    }
    public int hashCode() {
        return Objects.hash(idEvenement, codeTicket, numeroPlace);
    }
}
