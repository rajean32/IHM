package com.ihm.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "SALLE_TYPE_EVENEMENT")
public class SalleTypeEvenement {
    @EmbeddedId
    private SalleTypeEvenementId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("numeroSalle")
    @JoinColumn(name = "numeroSalle", referencedColumnName = "numeroSalle")
    private Salle salle;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("codeCategorie")
    @JoinColumn(name = "codeCategorie", referencedColumnName = "codeCategorie")
    private Categorie categorie;

    public SalleTypeEvenement() {}

    public SalleTypeEvenementId getId() { return id; }
    public void setId(SalleTypeEvenementId id) { this.id = id; }
    public Salle getSalle() { return salle; }
    public void setSalle(Salle salle) { this.salle = salle; }
    public Categorie getCategorie() { return categorie; }
    public void setCategorie(Categorie categorie) { this.categorie = categorie; }

    @Embeddable
    public static class SalleTypeEvenementId implements Serializable {
        @Column(name = "numeroSalle", length = 50)
        private String numeroSalle;

        @Column(name = "codeCategorie", length = 50)
        private String codeCategorie;

        public SalleTypeEvenementId() {}

        public SalleTypeEvenementId(String numeroSalle, String codeCategorie) {
            this.numeroSalle = numeroSalle;
            this.codeCategorie = codeCategorie;
        }

        public String getNumeroSalle() { return numeroSalle; }
        public void setNumeroSalle(String numeroSalle) { this.numeroSalle = numeroSalle; }
        public String getCodeCategorie() { return codeCategorie; }
        public void setCodeCategorie(String codeCategorie) { this.codeCategorie = codeCategorie; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof SalleTypeEvenementId that)) return false;
            return Objects.equals(numeroSalle, that.numeroSalle) && Objects.equals(codeCategorie, that.codeCategorie);
        }

        @Override
        public int hashCode() { return Objects.hash(numeroSalle, codeCategorie); }
    }
}
