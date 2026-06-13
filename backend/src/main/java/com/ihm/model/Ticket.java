package com.ihm.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
@Entity
@Table(name = "TICKET")
public class Ticket {
    @Id
    @Column(name = "CodeTicket", length = 50)
    @NotBlank(message = "Ticket code is required")
    private String codeTicket;
    @Column(name = "prix", precision = 10, scale = 2, nullable = false)
    @DecimalMin(value = "0.0", inclusive = true, message = "Price must be positive")
    private BigDecimal prix;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_zone", nullable = true)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private ZoneStanding zoneStanding;

    @OneToMany(mappedBy = "ticket", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Concerner> concerners = new ArrayList<>();
    @OneToMany(mappedBy = "ticket", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CorrespondA> correspondances = new ArrayList<>();
    public Ticket() {}
    public String getCodeTicket() { return codeTicket; }
    public void setCodeTicket(String codeTicket) { this.codeTicket = codeTicket; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public ZoneStanding getZoneStanding() { return zoneStanding; }
    public void setZoneStanding(ZoneStanding zoneStanding) { this.zoneStanding = zoneStanding; }
    public List<Concerner> getConcerners() { return concerners; }
    public void setConcerners(List<Concerner> concerners) { this.concerners = concerners; }
    public List<CorrespondA> getCorrespondances() { return correspondances; }
    public void setCorrespondances(List<CorrespondA> correspondances) { this.correspondances = correspondances; }
}
