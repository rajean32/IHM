package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.TicketDTO;
import com.ihm.repository.TicketRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
class TicketControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private TicketRepository repository;

    @BeforeEach
    void setUp() {
        repository.deleteAll();
    }

    @Test
    void testCreateAndGetTicket() throws Exception {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT001");
        dto.setPrix(new BigDecimal("50.00"));

        mockMvc.perform(post("/api/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.codeTicket").value("TKT001"));

        mockMvc.perform(get("/api/tickets/TKT001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.prix").value(50.00));
    }

    @Test
    void testGetAllTickets() throws Exception {
        TicketDTO dto1 = new TicketDTO();
        dto1.setCodeTicket("TKT001");
        dto1.setPrix(new BigDecimal("30.00"));
        mockMvc.perform(post("/api/tickets")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto1)));

        TicketDTO dto2 = new TicketDTO();
        dto2.setCodeTicket("TKT002");
        dto2.setPrix(new BigDecimal("60.00"));
        mockMvc.perform(post("/api/tickets")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto2)));

        mockMvc.perform(get("/api/tickets"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testCreateDuplicateTicket() throws Exception {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT001");
        dto.setPrix(new BigDecimal("50.00"));
        mockMvc.perform(post("/api/tickets")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(post("/api/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isConflict());
    }

    @Test
    void testUpdateTicket() throws Exception {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT001");
        dto.setPrix(new BigDecimal("50.00"));
        mockMvc.perform(post("/api/tickets")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        dto.setPrix(new BigDecimal("75.00"));
        mockMvc.perform(put("/api/tickets/TKT001")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.prix").value(75.00));
    }

    @Test
    void testDeleteTicket() throws Exception {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT001");
        dto.setPrix(new BigDecimal("50.00"));
        mockMvc.perform(post("/api/tickets")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)));

        mockMvc.perform(delete("/api/tickets/TKT001"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/tickets/TKT001"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testGetNonExistentTicket() throws Exception {
        mockMvc.perform(get("/api/tickets/INVALID"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testCreateWithNegativePrice() throws Exception {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT001");
        dto.setPrix(new BigDecimal("-10.00"));
        mockMvc.perform(post("/api/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest());
    }
}
