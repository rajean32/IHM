package com.ihm.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.schema.ReservationDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@WithMockUser
public class PurchaseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testPurchaseWithEmptyPayload() throws Exception {
        String json = objectMapper.writeValueAsString(new ReservationDTO.PurchaseRequest());
        mockMvc.perform(post("/api/achat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    @Test
    void testPurchaseWithMissingFields() throws Exception {
        ReservationDTO.PurchaseRequest req = new ReservationDTO.PurchaseRequest();
        ReservationDTO.PurchaseRequest.PurchaseTicketItem item = new ReservationDTO.PurchaseRequest.PurchaseTicketItem();
        item.setCodeTicket("");
        item.setNumeroPlace("");
        req.setTickets(List.of(item));
        String json = objectMapper.writeValueAsString(req);
        mockMvc.perform(post("/api/achat")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }
}
