package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.*;
import com.ihm.repository.*;
import com.ihm.model.Administrateur;
import com.ihm.model.Categorie;
import com.ihm.model.Lieu;
import com.ihm.model.Organisateur;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class EvenementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private EvenementRepository evenementRepository;
    @Autowired
    private CategorieRepository categorieRepository;
    @Autowired
    private LieuRepository lieuRepository;
    @Autowired
    private OrganisateurRepository organisateurRepository;
    @Autowired
    private AdministrateurRepository administrateurRepository;
    @Autowired
    private UtilisateurRepository utilisateurRepository;

    private String organisateurCode;
    private String categorieCode;
    private String lieuCode;

    @BeforeEach
    void setUp() throws Exception {
        evenementRepository.deleteAll();
        organisateurRepository.deleteAll();
        utilisateurRepository.deleteAll();
        categorieRepository.deleteAll();
        lieuRepository.deleteAll();
        administrateurRepository.deleteAll();

        Administrateur admin = new Administrateur("ADM_EVT", "pass");
        administrateurRepository.save(admin);

        Organisateur org = new Organisateur();
        org.setCodeUtilisateur("ORG_EVT");
        org.setNom("Dupont");
        org.setPrenoms("Jean");
        org.setSexe("M");
        org.setDateDeNaissance(LocalDate.of(1990, 1, 1));
        org.setEmail("org.evt@test.com");
        org.setTel("0102030405");
        org.setMotDePasse("pass");
        org.setAdministrateur(admin);
        organisateurRepository.save(org);
        organisateurCode = "ORG_EVT";

        Categorie cat = new Categorie("CAT_EVT", "Concert");
        categorieRepository.save(cat);
        categorieCode = "CAT_EVT";

        Lieu lieu = new Lieu();
        lieu.setCode("SALTEST");
        lieu.setNomLieu("Salle de Test");
        lieu.setVille("Paris");
        lieu = lieuRepository.save(lieu);
        lieuCode = lieu.getCode();
    }

    @Test
    void testCreateAndGetEvenement() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Concert de Jazz");
        dto.setDescription("Un super concert");
        dto.setDateEvenement(LocalDate.now().plusDays(30));
        dto.setHeureEvenement(LocalTime.of(20, 0));
        dto.setStatut("planifie");
        dto.setCodeCategorie(categorieCode);
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);

        mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.titre").value("Concert de Jazz"));
    }

    @Test
    void testCreateEvenementWithoutOrganisateur() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Event sans organisateur");
        dto.setDateEvenement(LocalDate.now().plusDays(10));
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur("");

        mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testGetEvenementByStatut() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Concert");
        dto.setDateEvenement(LocalDate.now().plusDays(30));
        dto.setStatut("planifie");
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);
        mockMvc.perform(post("/api/evenements")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(get("/api/evenements?statut=planifie"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1));
    }

    @Test
    void testGetNonExistentEvenement() throws Exception {
        mockMvc.perform(get("/api/evenements/99999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testDeleteEvenement() throws Exception {
        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Event to delete");
        dto.setDateEvenement(LocalDate.now().plusDays(15));
        dto.setCodeLieu(lieuCode);
        dto.setCodeOrganisateur(organisateurCode);

        MvcResult result = mockMvc.perform(post("/api/evenements")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        int id = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("idEvenement").asInt();

        mockMvc.perform(delete("/api/evenements/" + id))
                .andExpect(status().isOk());
    }
}
