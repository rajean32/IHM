package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser(roles = "ADMINISTRATEUR")
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private EvenementRepository evenementRepository;
    @Autowired
    private CategorieRepository categorieRepository;
    @Autowired
    private LieuRepository lieuRepository;
    @Autowired
    private SalleRepository salleRepository;
    @Autowired
    private OrganisateurRepository organisateurRepository;
    @Autowired
    private AdministrateurRepository administrateurRepository;
    @Autowired
    private UtilisateurRepository utilisateurRepository;
    @Autowired
    private ClientRepository clientRepository;

    @BeforeEach
    void setUp() {
        evenementRepository.deleteAll();
        organisateurRepository.deleteAll();
        clientRepository.deleteAll();
        utilisateurRepository.deleteAll();
        categorieRepository.deleteAll();
        lieuRepository.deleteAll();
        salleRepository.deleteAll();
        administrateurRepository.deleteAll();
    }

    private Administrateur createAdmin(String code) {
        Administrateur admin = new Administrateur(code, "pass");
        return administrateurRepository.save(admin);
    }

    private Organisateur createOrga(String code, Administrateur admin) {
        Organisateur org = new Organisateur();
        org.setCodeUtilisateur(code);
        org.setNom("Org");
        org.setPrenoms("Test");
        org.setSexe("M");
        org.setDateDeNaissance(LocalDate.of(1990, 1, 1));
        org.setEmail(code + "@test.com");
        org.setTel("0100000001");
        org.setMotDePasse("pass");
        org.setAdministrateur(admin);
        return organisateurRepository.save(org);
    }

    @Test
    void testAdminDashboardReturns200() throws Exception {
        createAdmin("ADM_DASH");
        mockMvc.perform(get("/api/admin/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void testAdminDashboardWithData() throws Exception {
        Administrateur admin = createAdmin("ADM_DASH2");
        Organisateur org = createOrga("ORG_DASH", admin);

        Client client = new Client();
        client.setCodeUtilisateur("CLT_DASH");
        client.setNom("Client");
        client.setPrenoms("Test");
        client.setSexe("M");
        client.setDateDeNaissance(LocalDate.of(1995, 1, 1));
        client.setEmail("client.dash@test.com");
        client.setTel("0100000002");
        client.setMotDePasse("pass");
        client.setAdministrateur(admin);
        clientRepository.save(client);

        Categorie cat = new Categorie("CAT_DASH", "Concert");
        categorieRepository.save(cat);

        Lieu lieu = new Lieu();
        lieu.setNomLieu("Test Lieu");
        lieu.setVille("Test");
        lieu = lieuRepository.save(lieu);

        Salle salle = new Salle();
        salle.setNumeroSalle("S001");
        salle.setNomSalle("Salle Test");
        salle.setLieu(lieu);
        salleRepository.save(salle);

        Evenement event = new Evenement();
        event.setTitre("Test Event");
        event.setDateEvenement(LocalDate.now());
        event.setHeureEvenement(LocalTime.of(10, 0));
        event.setStatut("planifie");
        event.setCategorie(cat);
        event.setLieu(lieu);
        event.setOrganisateur(org);
        evenementRepository.save(event);

        mockMvc.perform(get("/api/admin/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.totalEvents").value(1))
                .andExpect(jsonPath("$.data.totalClients").value(1))
                .andExpect(jsonPath("$.data.totalOrganisateurs").value(1))
                .andExpect(jsonPath("$.data.totalLieux").value(1))
                .andExpect(jsonPath("$.data.totalSalles").value(1));
    }

    @Test
    void testAdminDashboardWithNullStatut() throws Exception {
        Administrateur admin = createAdmin("ADM_DASH3");
        Organisateur org = createOrga("ORG_DASH2", admin);

        Categorie cat = new Categorie("CAT_NS", "Festival");
        categorieRepository.save(cat);

        Lieu lieu = new Lieu();
        lieu.setNomLieu("Place Event");
        lieu.setVille("Test");
        lieu = lieuRepository.save(lieu);

        Evenement event = new Evenement();
        event.setTitre("Null Statut Event");
        event.setDateEvenement(LocalDate.now());
        event.setHeureEvenement(LocalTime.of(14, 0));
        event.setStatut(null);
        event.setCategorie(cat);
        event.setLieu(lieu);
        event.setOrganisateur(org);
        evenementRepository.save(event);

        mockMvc.perform(get("/api/admin/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
