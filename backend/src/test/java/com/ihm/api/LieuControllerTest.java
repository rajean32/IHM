package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.LieuDTO;
import com.ihm.repository.LieuRepository;
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
class LieuControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private LieuRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testCreateAndGetLieu() throws Exception {
        LieuDTO dto = new LieuDTO();
        dto.setCode("PALAIS01");
        dto.setNomLieu("Palais des Sports");
        dto.setAdresse("123 Rue du Sport");
        dto.setVille("Paris");

        MvcResult result = mockMvc.perform(post("/api/lieux")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.nomLieu").value("Palais des Sports"))
                .andReturn();

        String response = result.getResponse().getContentAsString();
        String code = objectMapper.readTree(response).get("data").get("code").asText();

        mockMvc.perform(get("/api/lieux/" + code))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.nomLieu").value("Palais des Sports"));
    }

    @Test
    void testGetAllLieux() throws Exception {
        LieuDTO dto1 = new LieuDTO();
        dto1.setCode("PALAIS01");
        dto1.setNomLieu("Palais des Sports");
        dto1.setVille("Paris");
        mockMvc.perform(post("/api/lieux")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto1)));

        LieuDTO dto2 = new LieuDTO();
        dto2.setCode("STADE01");
        dto2.setNomLieu("Stade Municipal");
        dto2.setVille("Lyon");
        mockMvc.perform(post("/api/lieux")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto2)));

        mockMvc.perform(get("/api/lieux"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testUpdateLieu() throws Exception {
        LieuDTO dto = new LieuDTO();
        dto.setCode("OLD001");
        dto.setNomLieu("Old Name");
        dto.setVille("Paris");

        MvcResult result = mockMvc.perform(post("/api/lieux")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        String code = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("code").asText();

        dto.setNomLieu("New Name");
        mockMvc.perform(put("/api/lieux/" + code)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.nomLieu").value("New Name"));
    }

    @Test
    void testDeleteLieu() throws Exception {
        LieuDTO dto = new LieuDTO();
        dto.setCode("DELETE01");
        dto.setNomLieu("Place to Delete");
        dto.setVille("Marseille");

        MvcResult result = mockMvc.perform(post("/api/lieux")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andReturn();

        String code = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("data").get("code").asText();

        mockMvc.perform(delete("/api/lieux/" + code))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/lieux/" + code))
                .andExpect(status().isNotFound());
    }

    @Test
    void testGetNonExistentLieu() throws Exception {
        mockMvc.perform(get("/api/lieux/INEXISTANT"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testCreateWithInvalidData() throws Exception {
        LieuDTO dto = new LieuDTO();
        dto.setCode("INVAL");
        dto.setNomLieu("");
        mockMvc.perform(post("/api/lieux")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}
