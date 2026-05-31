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
import java.util.List;

@Service
public class PurchaseService {

    private static final Logger log = LoggerFactory.getLogger(PurchaseService.class);

    private final ClientRepository clientRepository;
    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;
    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final ReservationRepository reservationRepository;
    private final CorrespondARepository correspondARepository;
    private final PaiementRepository paiementRepository;

    public PurchaseService(ClientRepository clientRepository,
                           TicketRepository ticketRepository,
                           ConcernerRepository concernerRepository,
                           EvenementRepository evenementRepository,
                           PlaceRepository placeRepository,
                           ReservationRepository reservationRepository,
                           CorrespondARepository correspondARepository,
                           PaiementRepository paiementRepository) {
        this.clientRepository = clientRepository;
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.reservationRepository = reservationRepository;
        this.correspondARepository = correspondARepository;
        this.paiementRepository = paiementRepository;
    }

    @Transactional
    public Reservation processPurchase(PurchaseRequest request) {
        log.info("Processing purchase for client: {} ({} tickets, total: {})",
                request.getCodeClient(), request.getTickets().size(), request.getMontant());

        Client client = clientRepository.findByCodeUtilisateur(request.getCodeClient())
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", request.getCodeClient()));

        for (PurchaseTicketItem item : request.getTickets()) {
            if (concernerRepository.existsByEvenement_IdEvenementAndPlace_NumeroPlace(
                    item.getIdEvenement(), item.getNumeroPlace())) {
                throw new BadRequestException("Place " + item.getNumeroPlace()
                        + " is already reserved for this event (concurrent purchase detected)");
            }
        }

        BigDecimal totalCheck = BigDecimal.ZERO;
        List<Ticket> tickets = new ArrayList<>();
        for (PurchaseTicketItem item : request.getTickets()) {
            Ticket ticket = new Ticket();
            ticket.setCodeTicket(item.getCodeTicket());
            ticket.setPrix(item.getPrix());
            Ticket saved = ticketRepository.save(ticket);

            Evenement event = evenementRepository.findByIdEvenement(item.getIdEvenement())
                    .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", item.getIdEvenement()));
            Place place = placeRepository.findByNumeroPlace(item.getNumeroPlace())
                    .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", item.getNumeroPlace()));

            ConcernerId concernerId = new ConcernerId(item.getIdEvenement(), item.getCodeTicket(), item.getNumeroPlace());
            Concerner concerner = new Concerner();
            concerner.setId(concernerId);
            concerner.setEvenement(event);
            concerner.setTicket(saved);
            concerner.setPlace(place);
            concernerRepository.save(concerner);

            place.setStatut(StatutPlace.RESERVEE);
            placeRepository.save(place);

            tickets.add(saved);
            totalCheck = totalCheck.add(item.getPrix() != null ? item.getPrix() : BigDecimal.ZERO);
        }

        if (totalCheck.compareTo(request.getMontant()) != 0) {
            throw new BadRequestException("Total amount mismatch: expected " + totalCheck + " but got " + request.getMontant());
        }

        if ("SIMULATION_FONDS_INSUFFISANTS".equals(request.getModePaiement())) {
            throw new BadRequestException("Fonds insuffisants : solde insuffisant pour effectuer cette transaction");
        }

        Reservation reservation = new Reservation();
        reservation.setDateReservation(LocalDateTime.now());
        reservation.setClient(client);
        Reservation savedReservation = reservationRepository.save(reservation);

        for (Ticket ticket : tickets) {
            CorrespondAId corrId = new CorrespondAId(ticket.getCodeTicket(), savedReservation.getIdReservation());
            CorrespondA corr = new CorrespondA();
            corr.setId(corrId);
            corr.setTicket(ticket);
            corr.setReservation(savedReservation);
            correspondARepository.save(corr);
        }

        if (!"SIMULATION_ECHEC".equals(request.getModePaiement())) {
            Paiement paiement = new Paiement();
            paiement.setMontant(request.getMontant());
            paiement.setDatePaiement(LocalDateTime.now());
            paiement.setModePaiement(request.getModePaiement());
            paiement.setReservation(savedReservation);
            paiementRepository.save(paiement);
        }

        log.info("Purchase completed: reservation id={}, {} tickets, amount={}",
                savedReservation.getIdReservation(), tickets.size(), request.getMontant());
        return savedReservation;
    }
}
