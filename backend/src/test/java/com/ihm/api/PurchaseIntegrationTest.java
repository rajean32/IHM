package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.ReservationDTO;
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
import java.time.LocalTime;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class PurchaseIntegrationTest {

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

    private String clientCode;
    private String organisateurCode;
    private String categorieCode;
    private String lieuCode;
    private String salleNumero;
    private String placeNumero;
    private Integer evenementId;

    @BeforeEach
    void setUp() throws Exception {
        paiementRepository.deleteAll();
        correspondARepository.deleteAll();
        concernerRepository.deleteAll();
        reservationRepository.deleteAll();
        ticketRepository.deleteAll();
        evenementRepository.deleteAll();
        placeRepository.deleteAll();
        salleRepository.deleteAll();
        lieuRepository.deleteAll();
        categorieRepository.deleteAll();
        organisateurRepository.deleteAll();
        clientRepository.deleteAll();
        administrateurRepository.deleteAll();

        Administrateur admin = new Administrateur("ADM_PUR", "pass123");
        administrateurRepository.save(admin);

        Organisateur org = new Organisateur();
        org.setCodeUtilisateur("ORG_PUR");
        org.setNom("Martin");
        org.setPrenoms("Pierre");
        org.setSexe("M");
        org.setDateDeNaissance(LocalDate.of(1985, 5, 15));
        org.setEmail("org.pur@test.com");
        org.setTel("0601020304");
        org.setMotDePasse("pass");
        org.setAdministrateur(admin);
        organisateurRepository.save(org);
        organisateurCode = "ORG_PUR";

        Client cli = new Client();
        cli.setCodeUtilisateur("CLI_PUR");
        cli.setNom("Durand");
        cli.setPrenoms("Sophie");
        cli.setSexe("F");
        cli.setDateDeNaissance(LocalDate.of(1995, 8, 20));
        cli.setEmail("client.pur@test.com");
        cli.setTel("0612345678");
        cli.setMotDePasse("pass");
        cli.setAdministrateur(admin);
        clientRepository.save(cli);
        clientCode = "CLI_PUR";

        Categorie cat = new Categorie("CAT_PUR", "Test Category");
        categorieRepository.save(cat);
        categorieCode = "CAT_PUR";

        Lieu lieu = new Lieu();
        lieu.setCode("VENUE01");
        lieu.setNomLieu("Test Venue");
        lieu.setAdresse("123 Test St");
        lieu.setVille("Test City");
        lieu = lieuRepository.save(lieu);
        lieuCode = lieu.getCode();

        Salle salle = new Salle();
        salle.setNumeroSalle("SAL_PUR");
        salle.setNomSalle("Test Room");
        salle.setLieu(lieu);
        salleRepository.save(salle);
        salleNumero = "SAL_PUR";

        Place place = new Place();
        place.setNumeroPlace("PLA_PUR");
        place.setRange("A");
        place.setTypePlace("Normal");
        place.setPrix(new BigDecimal("50.00"));
        place.setSalle(salle);
        placeRepository.save(place);
        placeNumero = "PLA_PUR";
    }

    @Test
    void testFullPurchaseFlow() throws Exception {
        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient(clientCode);
        req.setModePaiement("GRATUIT");
        req.setMontant(BigDecimal.ZERO);

        PurchaseTicketItem item = new PurchaseTicketItem();
        item.setCodeTicket("TKT_PUR_001");
        item.setNumeroPlace(placeNumero);
        item.setIdEvenement(createEvent());
        item.setPrix(new BigDecimal("50.00"));
        req.setTickets(List.of(item));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.idReservation").isNumber())
                .andExpect(jsonPath("$.data.status").value("CONFIRMED"))
                .andExpect(jsonPath("$.data.codeClient").value(clientCode));
    }

    @Test
    void testPurchaseWithNonExistentPlace() throws Exception {
        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient(clientCode);
        req.setModePaiement("GRATUIT");
        req.setMontant(BigDecimal.ZERO);

        PurchaseTicketItem item = new PurchaseTicketItem();
        item.setCodeTicket("TKT_BAD");
        item.setNumeroPlace("DOES_NOT_EXIST");
        item.setIdEvenement(createEvent());
        req.setTickets(List.of(item));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());
    }

    @Test
    void testPurchaseWithoutClient() throws Exception {
        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient("");
        PurchaseTicketItem item = new PurchaseTicketItem();
        item.setCodeTicket("TKT_NOCLI");
        item.setNumeroPlace(placeNumero);
        item.setIdEvenement(createEvent());
        req.setTickets(List.of(item));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testPurchaseReservedPlaceShouldFail() throws Exception {
        createEvent();

        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient(clientCode);
        req.setModePaiement("GRATUIT");
        req.setMontant(BigDecimal.ZERO);

        PurchaseTicketItem item = new PurchaseTicketItem();
        item.setCodeTicket("TKT_FIRST");
        item.setNumeroPlace(placeNumero);
        item.setIdEvenement(evenementId);
        item.setPrix(new BigDecimal("50.00"));
        req.setTickets(List.of(item));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());

        ReservationDTO.PurchaseRequest req2 = new ReservationDTO.PurchaseRequest();
        req2.setCodeClient(clientCode);
        PurchaseTicketItem item2 = new PurchaseTicketItem();
        item2.setCodeTicket("TKT_SECOND");
        item2.setNumeroPlace(placeNumero);
        item2.setIdEvenement(evenementId);
        item2.setPrix(new BigDecimal("50.00"));
        req2.setTickets(List.of(item2));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req2)))
                .andExpect(status().isCreated());
    }

    @Test
    void testPurchaseWithSimulatedPaymentFailure() throws Exception {
        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        req.setCodeClient(clientCode);
        req.setModePaiement("SIMULATION_FONDS_INSUFFISANTS");
        req.setMontant(new BigDecimal("999999.00"));

        PurchaseTicketItem item = new PurchaseTicketItem();
        item.setCodeTicket("TKT_FAIL");
        item.setNumeroPlace(placeNumero);
        item.setIdEvenement(createEvent());
        item.setPrix(new BigDecimal("999999.00"));
        req.setTickets(List.of(item));

        mockMvc.perform(post("/api/achat")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());
    }

    private Integer createEvent() throws Exception {
        if (evenementId != null) return evenementId;
        com.ihm.schema.EvenementDTO dto = new com.ihm.schema.EvenementDTO();
        dto.setTitre("Purchase Test Event");
        dto.setDescription("Test event for purchase flow");
        dto.setDateEvenement(LocalDate.now().plusDays(60));
        dto.setHeureEvenement(LocalTime.of(21, 0));
        dto.setStatut("planifie");
        dto.setCodeCategorie(categorieCode);
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);

        var result = mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        evenementId = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idEvenement").asInt();
        return evenementId;
    }
}
