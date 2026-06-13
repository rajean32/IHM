package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.*;
import com.ihm.schema.ReservationDTO.PurchaseRequest.PurchaseTicketItem;
import com.ihm.repository.*;
import com.ihm.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class StandingZoneIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private AdministrateurRepository administrateurRepository;
    @Autowired private OrganisateurRepository organisateurRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private CategorieRepository categorieRepository;
    @Autowired private LieuRepository lieuRepository;
    @Autowired private SalleRepository salleRepository;
    @Autowired private PlaceRepository placeRepository;
    @Autowired private TicketRepository ticketRepository;
    @Autowired private ReservationRepository reservationRepository;
    @Autowired private CorrespondARepository correspondARepository;
    @Autowired private ConcernerRepository concernerRepository;
    @Autowired private EvenementRepository evenementRepository;
    @Autowired private PaiementRepository paiementRepository;
    @Autowired private ZoneStandingRepository zoneStandingRepository;

    private String clientCode;
    private String organisateurCode;
    private String categorieCode;
    private String lieuCode;
    private Integer evenementId;

    @BeforeEach
    void setUp() throws Exception {
        paiementRepository.deleteAll();
        correspondARepository.deleteAll();
        concernerRepository.deleteAll();
        reservationRepository.deleteAll();
        ticketRepository.deleteAll();
        zoneStandingRepository.deleteAll();
        evenementRepository.deleteAll();
        placeRepository.deleteAll();
        salleRepository.deleteAll();
        lieuRepository.deleteAll();
        categorieRepository.deleteAll();
        organisateurRepository.deleteAll();
        clientRepository.deleteAll();
        administrateurRepository.deleteAll();

        Administrateur admin = new Administrateur("ADM_SZ", "pass123");
        administrateurRepository.save(admin);

        Organisateur org = new Organisateur();
        org.setCodeUtilisateur("ORG_SZ");
        org.setNom("Martin");
        org.setPrenoms("Pierre");
        org.setSexe("M");
        org.setDateDeNaissance(LocalDate.of(1985, 5, 15));
        org.setEmail("org.sz@test.com");
        org.setTel("0601020304");
        org.setMotDePasse("pass");
        org.setAdministrateur(admin);
        organisateurRepository.save(org);
        organisateurCode = "ORG_SZ";

        Client cli = new Client();
        cli.setCodeUtilisateur("CLI_SZ");
        cli.setNom("Durand");
        cli.setPrenoms("Sophie");
        cli.setSexe("F");
        cli.setDateDeNaissance(LocalDate.of(1995, 8, 20));
        cli.setEmail("client.sz@test.com");
        cli.setTel("0612345678");
        cli.setMotDePasse("pass");
        cli.setAdministrateur(admin);
        clientRepository.save(cli);
        clientCode = "CLI_SZ";

        Categorie cat = new Categorie("CAT_SZ", "Standing Category");
        categorieRepository.save(cat);
        categorieCode = "CAT_SZ";

        Lieu lieu = new Lieu();
        lieu.setCode("VENUE_SZ");
        lieu.setNomLieu("Standing Venue");
        lieu.setAdresse("123 Test St");
        lieu.setVille("Test City");
        lieu = lieuRepository.save(lieu);
        lieuCode = lieu.getCode();
    }

    private int createEventWithStanding() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Standing Concert");
        dto.setDescription("Test event for standing zones");
        dto.setDateEvenement(LocalDate.now().plusDays(60));
        dto.setHeureEvenement(LocalTime.of(21, 0));
        dto.setStatut("planifie");
        dto.setCodeCategorie(categorieCode);
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);
        dto.setTypeAgencement(TypeAgencement.DEBOUT_AVEC_LIMITE);

        var result = mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.typeAgencement").value("DEBOUT_AVEC_LIMITE"))
                .andReturn();

        evenementId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idEvenement").asInt();
        return evenementId;
    }

    private int createStandingZone(int eventId, String nom, Integer capacite, BigDecimal prix) throws Exception {
        ZoneStandingDTO dto = new ZoneStandingDTO();
        dto.setNom(nom);
        dto.setCapacite(capacite);
        dto.setPrix(prix);

        var result = mockMvc.perform(post("/api/evenements/{eventId}/zones", eventId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        return objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idZone").asInt();
    }

    @Test
    void test1_CreateEventWithStandingZones() throws Exception {
        int eventId = createEventWithStanding();

        int zoneId = createStandingZone(eventId, "Fosse", 100, new BigDecimal("30.00"));

        mockMvc.perform(get("/api/evenements/{eventId}/zones", eventId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].nom").value("Fosse"))
                .andExpect(jsonPath("$.data[0].capacite").value(100))
                .andExpect(jsonPath("$.data[0].reservationsActuelles").value(0))
                .andExpect(jsonPath("$.data[0].prix").value(30.0));
    }

    @Test
    void test2_CreateTicketWithIdZone() throws Exception {
        int eventId = createEventWithStanding();
        int zoneId = createStandingZone(eventId, "Fosse", 100, new BigDecimal("30.00"));

        TicketDTO ticketDto = new TicketDTO();
        ticketDto.setCodeTicket("TKT_SZ_001");
        ticketDto.setPrix(new BigDecimal("30.00"));
        ticketDto.setIdEvenement(eventId);
        ticketDto.setIdZone(zoneId);

        mockMvc.perform(post("/api/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(ticketDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.codeTicket").value("TKT_SZ_001"))
                .andExpect(jsonPath("$.data.zoneNom").value("Fosse"));

        ZoneStanding zone = zoneStandingRepository.findById(zoneId).orElseThrow();
        assert zone.getReservationsActuelles() == 1 : "Expected 1 reservation, got " + zone.getReservationsActuelles();
    }

    @Test
    void test3_FullReservationFlowWithStanding() throws Exception {
        int eventId = createEventWithStanding();
        int zoneId = createStandingZone(eventId, "Fosse", 100, new BigDecimal("30.00"));

        TicketDTO t1 = new TicketDTO();
        t1.setCodeTicket("TKT_SZ_FULL_1");
        t1.setPrix(new BigDecimal("30.00"));
        t1.setIdEvenement(eventId);
        t1.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(t1))).andExpect(status().isCreated());

        TicketDTO t2 = new TicketDTO();
        t2.setCodeTicket("TKT_SZ_FULL_2");
        t2.setPrix(new BigDecimal("30.00"));
        t2.setIdEvenement(eventId);
        t2.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(t2))).andExpect(status().isCreated());

        ReservationDTO resDto = new ReservationDTO();
        resDto.setDateReservation(LocalDateTime.now());
        resDto.setCodeClient(clientCode);
        resDto.setCodeTickets(java.util.List.of("TKT_SZ_FULL_1", "TKT_SZ_FULL_2"));

        var resResult = mockMvc.perform(post("/api/reservations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.codeClient").value(clientCode))
                .andReturn();

        int reservationId = objectMapper.readTree(resResult.getResponse().getContentAsString())
                .get("data").get("idReservation").asInt();

        PaiementDTO payDto = new PaiementDTO();
        payDto.setMontant(new BigDecimal("60.00"));
        payDto.setDatePaiement(LocalDateTime.now());
        payDto.setModePaiement("Carte");
        payDto.setIdReservation(reservationId);

        mockMvc.perform(post("/api/paiements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(payDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.modePaiement").value("Carte"));

        ZoneStanding zone = zoneStandingRepository.findById(zoneId).orElseThrow();
        assert zone.getReservationsActuelles() == 2 : "Expected 2 reservations, got " + zone.getReservationsActuelles();
    }

    @Test
    void test4_PurchaseFlowWithStandingZone() throws Exception {
        int eventId = createEventWithStanding();
        int zoneId = createStandingZone(eventId, "Fosse", 100, new BigDecimal("30.00"));

        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient(clientCode);
        req.setModePaiement("GRATUIT");
        req.setMontant(new BigDecimal("60.00"));

        PurchaseTicketItem item1 = new PurchaseTicketItem();
        item1.setCodeTicket("TKT_PUR_SZ_1");
        item1.setPrix(new BigDecimal("30.00"));
        item1.setIdEvenement(eventId);
        item1.setIdZone(zoneId);

        PurchaseTicketItem item2 = new PurchaseTicketItem();
        item2.setCodeTicket("TKT_PUR_SZ_2");
        item2.setPrix(new BigDecimal("30.00"));
        item2.setIdEvenement(eventId);
        item2.setIdZone(zoneId);

        req.setTickets(java.util.List.of(item1, item2));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.status").value("CONFIRMED"))
                .andExpect(jsonPath("$.data.idReservation").isNumber());

        ZoneStanding zone = zoneStandingRepository.findById(zoneId).orElseThrow();
        assert zone.getReservationsActuelles() == 2 : "Expected 2 reservations, got " + zone.getReservationsActuelles();
    }

    @Test
    void test5_StandingZoneCapacityLimit() throws Exception {
        int eventId = createEventWithStanding();
        int zoneId = createStandingZone(eventId, "Petite Fosse", 2, new BigDecimal("30.00"));

        TicketDTO t1 = new TicketDTO();
        t1.setCodeTicket("TKT_CAP_1");
        t1.setPrix(new BigDecimal("30.00"));
        t1.setIdEvenement(eventId);
        t1.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(t1))).andExpect(status().isCreated());

        TicketDTO t2 = new TicketDTO();
        t2.setCodeTicket("TKT_CAP_2");
        t2.setPrix(new BigDecimal("30.00"));
        t2.setIdEvenement(eventId);
        t2.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(t2))).andExpect(status().isCreated());

        TicketDTO t3 = new TicketDTO();
        t3.setCodeTicket("TKT_CAP_3");
        t3.setPrix(new BigDecimal("30.00"));
        t3.setIdEvenement(eventId);
        t3.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(t3)))
                .andExpect(status().isBadRequest());

        ZoneStanding zone = zoneStandingRepository.findById(zoneId).orElseThrow();
        assert zone.getReservationsActuelles() == 2 : "Expected 2 reservations (capacity full), got " + zone.getReservationsActuelles();
    }

    @Test
    void test6_UnlimitedStandingZone() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Unlimited Standing Event");
        dto.setDateEvenement(LocalDate.now().plusDays(60));
        dto.setHeureEvenement(LocalTime.of(20, 0));
        dto.setStatut("planifie");
        dto.setCodeCategorie(categorieCode);
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);
        dto.setTypeAgencement(TypeAgencement.DEBOUT_SANS_LIMITE);

        var evResult = mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();
        int eventId = objectMapper.readTree(evResult.getResponse().getContentAsString())
                .get("data").get("idEvenement").asInt();

        ZoneStandingDTO zoneDto = new ZoneStandingDTO();
        zoneDto.setNom("Pelouse");
        zoneDto.setCapacite(null);
        zoneDto.setPrix(new BigDecimal("15.00"));
        var zoneResult = mockMvc.perform(post("/api/evenements/{eventId}/zones", eventId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(zoneDto)))
                .andExpect(status().isCreated())
                .andReturn();
        int zoneId = objectMapper.readTree(zoneResult.getResponse().getContentAsString())
                .get("data").get("idZone").asInt();

        for (int i = 0; i < 5; i++) {
            TicketDTO ticket = new TicketDTO();
            ticket.setCodeTicket("TKT_UNL_" + i);
            ticket.setPrix(new BigDecimal("15.00"));
            ticket.setIdEvenement(eventId);
            ticket.setIdZone(zoneId);
            mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(ticket))).andExpect(status().isCreated());
        }

        ZoneStanding zone = zoneStandingRepository.findById(zoneId).orElseThrow();
        assert zone.getReservationsActuelles() == 5 : "Expected 5 reservations (unlimited), got " + zone.getReservationsActuelles();
        assert zone.getCapacite() == null : "Capacity should be null for unlimited zone";
    }

    @Test
    void test7_EventDetailShowsStandingZones() throws Exception {
        int eventId = createEventWithStanding();
        int zoneId = createStandingZone(eventId, "Fosse", 100, new BigDecimal("30.00"));

        TicketDTO ticket = new TicketDTO();
        ticket.setCodeTicket("TKT_DETAIL");
        ticket.setPrix(new BigDecimal("30.00"));
        ticket.setIdEvenement(eventId);
        ticket.setIdZone(zoneId);
        mockMvc.perform(post("/api/tickets").contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(ticket))).andExpect(status().isCreated());

        mockMvc.perform(get("/api/evenements/{eventId}/detail", eventId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.typeAgencement").value("DEBOUT_AVEC_LIMITE"))
                .andExpect(jsonPath("$.data.placesTotal").value(0))
                .andExpect(jsonPath("$.data.placesDisponibles").value(0));
    }
}
