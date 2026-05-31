package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.model.dto.BatchPlaceRequest;
import com.ihm.model.dto.PlaceDTO;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class PlaceControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PlaceRepository placeRepository;
    @Autowired
    private SalleRepository salleRepository;
    @Autowired
    private LieuRepository lieuRepository;

    @BeforeEach
    void setUp() {
        placeRepository.deleteAll();
        salleRepository.deleteAll();
        lieuRepository.deleteAll();
    }

    @Test
    void testCreatePlace() throws Exception {
        Lieu lieu = new Lieu();
        lieu.setNomLieu("Test Lieu");
        lieu.setVille("Test");
        lieu = lieuRepository.save(lieu);

        Salle salle = new Salle();
        salle.setNumeroSalle("S001");
        salle.setNomSalle("Salle Test");
        salle.setLieu(lieu);
        salleRepository.save(salle);

        PlaceDTO dto = new PlaceDTO();
        dto.setNumeroPlace("A1");
        dto.setRange("A");
        dto.setTypePlace("Standard");
        dto.setNumeroSalle("S001");

        mockMvc.perform(post("/api/places")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.numeroPlace").value("Test Lieu - Salle Test - A - A1"));
    }

    @Test
    void testBatchCreatePlaces() throws Exception {
        Lieu lieu = new Lieu();
        lieu.setNomLieu("Test Lieu");
        lieu.setVille("Test");
        lieu = lieuRepository.save(lieu);

        Salle salle = new Salle();
        salle.setNumeroSalle("S002");
        salle.setNomSalle("Salle Batch");
        salle.setLieu(lieu);
        salleRepository.save(salle);

        BatchPlaceRequest request = new BatchPlaceRequest();
        request.setNumeroSalle("S002");
        request.setNombreRangees(3);
        request.setPlacesParRangee(5);
        request.setPrefixeRangee("");
        request.setTypePlace("Standard");

        MvcResult result = mockMvc.perform(post("/api/places/batch")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(15))
                .andReturn();

        String response = result.getResponse().getContentAsString();
        int createdCount = objectMapper.readTree(response).get("data").size();
        assert createdCount == 15 : "Expected 15 places, got " + createdCount;

        mockMvc.perform(get("/api/places?salle=S002"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(15));
    }

    @Test
    void testBatchCreateWithCustomPrefix() throws Exception {
        Lieu lieu = new Lieu();
        lieu.setNomLieu("Test Lieu");
        lieu.setVille("Test");
        lieu = lieuRepository.save(lieu);

        Salle salle = new Salle();
        salle.setNumeroSalle("S003");
        salle.setNomSalle("Salle VIP");
        salle.setLieu(lieu);
        salleRepository.save(salle);

        BatchPlaceRequest request = new BatchPlaceRequest();
        request.setNumeroSalle("S003");
        request.setNombreRangees(2);
        request.setPlacesParRangee(4);
        request.setPrefixeRangee("VIP-");
        request.setTypePlace("VIP");

        MvcResult result = mockMvc.perform(post("/api/places/batch")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(8))
                .andReturn();

        String response = result.getResponse().getContentAsString();
        String firstPlace = objectMapper.readTree(response).get("data").get(0).get("numeroPlace").asText();
        assert firstPlace.contains("VIP-A - 1") : "Expected VIP-A - 1 in combined key, got " + firstPlace;

        String lastPlace = objectMapper.readTree(response).get("data").get(7).get("numeroPlace").asText();
        assert lastPlace.contains("VIP-B - 4") : "Expected VIP-B - 4 in combined key, got " + lastPlace;
    }
}
