package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.CategorieDTO;
import com.ihm.repository.CategorieRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class CategorieControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private CategorieRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testCreateAndGetCategorie() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("CAT001");
        dto.setNomCategorie("Concert");

        mockMvc.perform(post("/api/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.nomCategorie").value("Concert"));

        mockMvc.perform(get("/api/categories/CAT001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.codeCategorie").value("CAT001"));
    }

    @Test
    void testGetAllCategories() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("CAT001");
        dto.setNomCategorie("Concert");
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        dto.setCodeCategorie("CAT002");
        dto.setNomCategorie("Festival");
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(get("/api/categories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testCreateDuplicateCategorie() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("CAT001");
        dto.setNomCategorie("Concert");
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(post("/api/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isConflict());
    }

    @Test
    void testUpdateCategorie() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("CAT001");
        dto.setNomCategorie("Concert");
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        dto.setNomCategorie("Festival");
        mockMvc.perform(put("/api/categories/CAT001")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.nomCategorie").value("Festival"));
    }

    @Test
    void testDeleteCategorie() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("CAT001");
        dto.setNomCategorie("Concert");
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(delete("/api/categories/CAT001"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/categories/CAT001"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testGetNonExistentCategorie() throws Exception {
        mockMvc.perform(get("/api/categories/INVALID"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testCreateWithInvalidData() throws Exception {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie("");
        dto.setNomCategorie("");
        mockMvc.perform(post("/api/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}
