package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.PurchaseRequest;
import com.ihm.model.dto.PurchaseRequest.PurchaseTicketItem;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PurchaseService {

    private static final Logger log = LoggerFactory.getLogger(PurchaseService.class);

    private final ClientRepository clientRepository;
    private final TicketRepository ticketRepository;
    private final ReservationRepository reservationRepository;
    private final CorrespondARepository correspondARepository;
    private final PaiementRepository paiementRepository;

    public PurchaseService(ClientRepository clientRepository,
                           TicketRepository ticketRepository,
                           ReservationRepository reservationRepository,
                           CorrespondARepository correspondARepository,
                           PaiementRepository paiementRepository) {
        this.clientRepository = clientRepository;
        this.ticketRepository = ticketRepository;
        this.reservationRepository = reservationRepository;
        this.correspondARepository = correspondARepository;
        this.paiementRepository = paiementRepository;
    }

    @Transactional
    public Map<String, Object> processPurchase(PurchaseRequest request) {
        log.info("Processing purchase for client: {} ({} tickets)", request.getCodeClient(),
                request.getTickets() != null ? request.getTickets().size() : 0);

        if (request.getCodeClient() == null || request.getCodeClient().isBlank()) {
            throw new BadRequestException("Client code is required");
        }
        if (request.getTickets() == null || request.getTickets().isEmpty()) {
            throw new BadRequestException("At least one ticket is required");
        }

        Client client = clientRepository.findByCodeUtilisateur(request.getCodeClient())
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", request.getCodeClient()));

        LocalDateTime now = LocalDateTime.now();
        String modePaiement = request.getModePaiement() != null ? request.getModePaiement() : "GRATUIT";
        BigDecimal montant = request.getMontant() != null ? request.getMontant() : BigDecimal.ZERO;

        List<Ticket> tickets = new ArrayList<>();
        for (PurchaseTicketItem item : request.getTickets()) {
            Ticket ticket = new Ticket();
            ticket.setCodeTicket(item.getCodeTicket());
            ticket.setPrix(item.getPrix() != null ? item.getPrix() : BigDecimal.ZERO);
            Ticket saved = ticketRepository.save(ticket);
            tickets.add(saved);
        }

        Reservation reservation = new Reservation();
        reservation.setDateReservation(now);
        reservation.setClient(client);
        Reservation savedReservation = reservationRepository.save(reservation);

        for (int i = 0; i < request.getTickets().size(); i++) {
            PurchaseTicketItem item = request.getTickets().get(i);
            Ticket saved = tickets.get(i);

            CorrespondAId corrId = new CorrespondAId(item.getCodeTicket(), savedReservation.getIdReservation());
            CorrespondA corr = new CorrespondA();
            corr.setId(corrId);
            corr.setTicket(saved);
            corr.setReservation(savedReservation);
            correspondARepository.save(corr);
        }

        Paiement paiement = new Paiement();
        paiement.setMontant(montant);
        paiement.setDatePaiement(now);
        paiement.setModePaiement(modePaiement);
        paiement.setReservation(savedReservation);
        paiementRepository.save(paiement);

        log.info("Purchase completed: reservation id={}, {} tickets, montant={}",
                savedReservation.getIdReservation(), tickets.size(), montant);

        Map<String, Object> result = new HashMap<>();
        result.put("idReservation", savedReservation.getIdReservation());
        result.put("dateReservation", savedReservation.getDateReservation().toString());
        result.put("codeClient", savedReservation.getClient().getCodeUtilisateur());
        result.put("status", "CONFIRMED");
        return result;
    }
}
