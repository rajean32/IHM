package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.*;
import com.ihm.repository.*;
import com.ihm.model.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class FullIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AdministrateurRepository administrateurRepository;
    @Autowired
    private OrganisateurRepository organisateurRepository;
    @Autowired
    private ClientRepository clientRepository;
    @Autowired
    private CategorieRepository categorieRepository;
    @Autowired
    private LieuRepository lieuRepository;
    @Autowired
    private SalleRepository salleRepository;
    @Autowired
    private PlaceRepository placeRepository;
    @Autowired
    private TicketRepository ticketRepository;
    @Autowired
    private ReservationRepository reservationRepository;
    @Autowired
    private CorrespondARepository correspondARepository;
    @Autowired
    private ConcernerRepository concernerRepository;
    @Autowired
    private EvenementRepository evenementRepository;
    @Autowired
    private PaiementRepository paiementRepository;
    @Autowired
    private EvenementPlaceConfigurationRepository configRepository;
    @Autowired
    private ZoneStandingRepository zoneStandingRepository;

    private String adminCode;
    private String organisateurCode;
    private String clientCode;
    private String categorieCode;
    private String lieuCode;
    private String salleNumero;
    private String placeNumero;
    private Integer evenementId;
    private String ticketCode;

    @BeforeEach
    void setUp() throws Exception {
        paiementRepository.deleteAll();
        correspondARepository.deleteAll();
        concernerRepository.deleteAll();
        reservationRepository.deleteAll();
        ticketRepository.deleteAll();
        configRepository.deleteAll();
        zoneStandingRepository.deleteAll();
        evenementRepository.deleteAll();
        placeRepository.deleteAll();
        salleRepository.deleteAll();
        lieuRepository.deleteAll();
        categorieRepository.deleteAll();
        organisateurRepository.deleteAll();
        clientRepository.deleteAll();
        administrateurRepository.deleteAll();

        Administrateur admin = new Administrateur("ADM_INT", "pass123");
        administrateurRepository.save(admin);
        adminCode = "ADM_INT";

        Organisateur org = new Organisateur();
        org.setCodeUtilisateur("ORG_INT");
        org.setNom("Martin");
        org.setPrenoms("Pierre");
        org.setSexe("M");
        org.setDateDeNaissance(LocalDate.of(1985, 5, 15));
        org.setEmail("org.int@test.com");
        org.setTel("0601020304");
        org.setMotDePasse("pass");
        org.setAdministrateur(admin);
        organisateurRepository.save(org);
        organisateurCode = "ORG_INT";

        Client cli = new Client();
        cli.setCodeUtilisateur("CLI_INT");
        cli.setNom("Durand");
        cli.setPrenoms("Sophie");
        cli.setSexe("F");
        cli.setDateDeNaissance(LocalDate.of(1995, 8, 20));
        cli.setEmail("client.int@test.com");
        cli.setTel("0612345678");
        cli.setMotDePasse("pass");
        cli.setAdministrateur(admin);
        clientRepository.save(cli);
        clientCode = "CLI_INT";

        Categorie cat = new Categorie("CAT_INT", "Test Category");
        categorieRepository.save(cat);
        categorieCode = "CAT_INT";

        Lieu lieu = new Lieu();
        lieu.setCode("VENUE02");
        lieu.setNomLieu("Test Venue");
        lieu.setAdresse("123 Test St");
        lieu.setVille("Test City");
        lieu = lieuRepository.save(lieu);
        lieuCode = lieu.getCode();

        Salle salle = new Salle();
        salle.setNumeroSalle("SAL_INT");
        salle.setNomSalle("Test Room");
        salle.setLieu(lieu);
        salle.setTypeAgencement(TypeAgencement.UNIQUEMENT_ASSIS);
        salleRepository.save(salle);
        salleNumero = "SAL_INT";

        Place place = new Place();
        place.setNumeroPlace("PLA_INT");
        place.setRangePlace("A");
        place.setSalle(salle);
        placeRepository.save(place);
        placeNumero = "PLA_INT";
    }

    @Test
    void testFullEventCreation() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Full Integration Concert");
        dto.setDescription("Full test event");
        dto.setDateEvenement(LocalDate.now().plusDays(60));
        dto.setHeureEvenement(LocalTime.of(21, 0));
        dto.setStatut("planifie");
        dto.setCodeCategorie(categorieCode);
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);

        MvcResult result = mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.titre").value("Full Integration Concert"))
                .andReturn();
        evenementId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idEvenement").asInt();
    }

    @Test
    void testFullTicketWithPlace() throws Exception {
        testFullEventCreation();

        TicketDTO ticketDto = new TicketDTO();
        ticketDto.setCodeTicket("TKT_INT");
        ticketDto.setPrix(new BigDecimal("100.00"));
        ticketDto.setIdEvenement(evenementId);
        ticketDto.setNumeroPlace(placeNumero);

        mockMvc.perform(post("/api/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(ticketDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.codeTicket").value("TKT_INT"));
        ticketCode = "TKT_INT";
    }

    @Test
    void testFullReservationFlow() throws Exception {
        testFullTicketWithPlace();

        ReservationDTO resDto = new ReservationDTO();
        resDto.setDateReservation(LocalDateTime.now());
        resDto.setCodeClient(clientCode);
        resDto.setCodeTickets(java.util.List.of(ticketCode));

        MvcResult result = mockMvc.perform(post("/api/reservations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.codeClient").value(clientCode))
                .andReturn();
        int reservationId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idReservation").asInt();

        PaiementDTO payDto = new PaiementDTO();
        payDto.setMontant(new BigDecimal("100.00"));
        payDto.setDatePaiement(LocalDateTime.now());
        payDto.setModePaiement("Carte");
        payDto.setIdReservation(reservationId);

        mockMvc.perform(post("/api/paiements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(payDto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.modePaiement").value("Carte"));
    }
}
