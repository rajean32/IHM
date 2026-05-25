package com.ihm.schemat;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ORGANISATEUR")
@PrimaryKeyJoinColumn(name = "CodeOrganisateur", referencedColumnName = "CodeUtilisateur")
public class Organisateur extends Utilisateur {

    @OneToMany(mappedBy = "organisateur", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Evenement> evenements = new ArrayList<>();

    public Organisateur() {}

    public List<Evenement> getEvenements() { return evenements; }
    public void setEvenements(List<Evenement> evenements) { this.evenements = evenements; }
}
