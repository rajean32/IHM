package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.ApiResponse;
import com.ihm.schema.UtilisateurDTO;
import com.ihm.repository.AdministrateurRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class AdministrateurControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private AdministrateurRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testCreateAndGetAdministrateur() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur("ADM001");
        dto.setMotdepasseAdministrateur("password123");

        MvcResult createResult = mockMvc.perform(post("/api/administrateurs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.status").value(201))
                .andExpect(jsonPath("$.data.codeAdministrateur").value("ADM001"))
                .andReturn();

        MvcResult getResult = mockMvc.perform(get("/api/administrateurs/ADM001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.codeAdministrateur").value("ADM001"))
                .andReturn();
    }

    @Test
    void testGetAllAdministrateurs() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto1 = new UtilisateurDTO.AdministrateurDTO();
        dto1.setCodeAdministrateur("ADM001");
        dto1.setMotdepasseAdministrateur("pass1");
        mockMvc.perform(post("/api/administrateurs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto1)));

        UtilisateurDTO.AdministrateurDTO dto2 = new UtilisateurDTO.AdministrateurDTO();
        dto2.setCodeAdministrateur("ADM002");
        dto2.setMotdepasseAdministrateur("pass2");
        mockMvc.perform(post("/api/administrateurs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto2)));

        mockMvc.perform(get("/api/administrateurs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testCreateDuplicateAdministrateur() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur("ADM001");
        dto.setMotdepasseAdministrateur("pass1");
        mockMvc.perform(post("/api/administrateurs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(post("/api/administrateurs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void testUpdateAdministrateur() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur("ADM001");
        dto.setMotdepasseAdministrateur("oldpass");
        mockMvc.perform(post("/api/administrateurs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        dto.setMotdepasseAdministrateur("newpass");
        mockMvc.perform(put("/api/administrateurs/ADM001")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void testDeleteAdministrateur() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur("ADM001");
        dto.setMotdepasseAdministrateur("pass1");
        mockMvc.perform(post("/api/administrateurs")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(delete("/api/administrateurs/ADM001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(get("/api/administrateurs/ADM001"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testGetNonExistentAdministrateur() throws Exception {
        mockMvc.perform(get("/api/administrateurs/INVALID"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void testCreateWithInvalidData() throws Exception {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur("");
        dto.setMotdepasseAdministrateur("");
        mockMvc.perform(post("/api/administrateurs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }
}
