package com.ihm.schemat;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class CorrespondAId implements Serializable {

    @Column(name = "CodeTicket", length = 50)
    private String codeTicket;

    @Column(name = "idReservation")
    private Integer idReservation;

    public CorrespondAId() {}

    public CorrespondAId(String codeTicket, Integer idReservation) {
        this.codeTicket = codeTicket;
        this.idReservation = idReservation;
    }

    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }

    public Integer getIdReservation() { return idReservation; }
    public void setIdReservation(Integer idReservation) { this.idReservation = idReservation; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CorrespondAId that)) return false;
        return Objects.equals(codeTicket, that.codeTicket)
                && Objects.equals(idReservation, that.idReservation);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codeTicket, idReservation);
    }
}
