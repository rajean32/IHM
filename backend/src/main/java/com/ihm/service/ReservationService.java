package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.ReservationDTO;
import com.ihm.schema.ReservationDTO.PurchaseRequest.PurchaseTicketItem;
import com.ihm.repository.*;
import com.ihm.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private static final Logger log = LoggerFactory.getLogger(ReservationService.class);

    private static final long EXPIRATION_MINUTES = 10;

    private final ReservationRepository reservationRepository;
    private final ClientRepository clientRepository;
    private final TicketRepository ticketRepository;
    private final CorrespondARepository correspondARepository;
    private final PaiementRepository paiementRepository;
    private final ConcernerRepository concernerRepository;
    private final PlaceRepository placeRepository;

    public ReservationService(ReservationRepository reservationRepository,
                              ClientRepository clientRepository,
                              TicketRepository ticketRepository,
                              CorrespondARepository correspondARepository,
                              PaiementRepository paiementRepository,
                              ConcernerRepository concernerRepository,
                              PlaceRepository placeRepository) {
        this.reservationRepository = reservationRepository;
        this.clientRepository = clientRepository;
        this.ticketRepository = ticketRepository;
        this.correspondARepository = correspondARepository;
        this.paiementRepository = paiementRepository;
        this.concernerRepository = concernerRepository;
        this.placeRepository = placeRepository;
    }

    // recuperation de toutes les reservations
    @Transactional(readOnly = true)
    public List<ReservationDTO> getAll() {
        log.debug("Fetching all reservations");
        return reservationRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'une reservation
    @Transactional(readOnly = true)
    public ReservationDTO getById(Integer id) {
        log.debug("Fetching reservation by id: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));
        return toDTO(reservation);
    }

    // reservations d'un client
    @Transactional(readOnly = true)
    public List<ReservationDTO> getByClient(String codeClient) {
        log.debug("Fetching reservations by client: {}", codeClient);
        return reservationRepository.findByClient_CodeUtilisateur(codeClient)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // creation d'une reservation
    @Transactional
    public ReservationDTO create(ReservationDTO dto) {
        log.debug("Creating reservation for client: {}", dto.getCodeClient());
        Client client = clientRepository.findByCodeUtilisateur(dto.getCodeClient())
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", dto.getCodeClient()));

        if (dto.getCodeTickets() != null && !dto.getCodeTickets().isEmpty()) {
            for (String codeTicket : dto.getCodeTickets()) {
                if (!correspondARepository.findByTicket_CodeTicket(codeTicket).isEmpty()) {
                    throw new BadRequestException("Ticket " + codeTicket + " is already used in another reservation");
                }
            }
        }

        Reservation reservation = new Reservation();
        reservation.setDateReservation(dto.getDateReservation() != null ? dto.getDateReservation() : LocalDateTime.now());
        reservation.setClient(client);
        Reservation saved = reservationRepository.save(reservation);

        if (dto.getCodeTickets() != null) {
            for (String codeTicket : dto.getCodeTickets()) {
                Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                        .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

                CorrespondAId corrId = new CorrespondAId(codeTicket, saved.getIdReservation());
                CorrespondA corr = new CorrespondA();
                corr.setId(corrId);
                corr.setTicket(ticket);
                corr.setReservation(saved);
                correspondARepository.save(corr);
            }
        }

        log.info("Reservation created: id={}", saved.getIdReservation());
        return toDTO(saved);
    }

    // mise a jour d'une reservation
    @Transactional
    public ReservationDTO update(Integer id, ReservationDTO dto) {
        log.debug("Updating reservation: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));

        if (paiementRepository.existsByReservation_IdReservation(id)) {
            throw new BadRequestException("Cannot update a reservation that has been paid");
        }

        if (dto.getDateReservation() != null) {
            reservation.setDateReservation(dto.getDateReservation());
        }

        if (dto.getCodeTickets() != null) {
            correspondARepository.findByReservation_IdReservation(id).forEach(correspondARepository::delete);

            for (String codeTicket : dto.getCodeTickets()) {
                Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                        .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

                CorrespondAId corrId = new CorrespondAId(codeTicket, reservation.getIdReservation());
                CorrespondA corr = new CorrespondA();
                corr.setId(corrId);
                corr.setTicket(ticket);
                corr.setReservation(reservation);
                correspondARepository.save(corr);
            }
        }

        Reservation saved = reservationRepository.save(reservation);
        log.info("Reservation updated: id={}", id);
        return toDTO(saved);
    }

    // annulation d'une reservation
    @Transactional
    public void cancel(Integer id) {
        log.debug("Cancelling reservation: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));

        List<CorrespondA> correspondances = correspondARepository.findByReservation_IdReservation(id);
        for (CorrespondA ca : correspondances) {
            List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
            for (Concerner c : concerners) {
                Place place = c.getPlace();
                if (place != null) {
                    place.setStatut(StatutPlace.DISPONIBLE);
                    placeRepository.save(place);
                }
            }
        }

        correspondances.forEach(correspondARepository::delete);

        paiementRepository.findByReservation_IdReservation(id).ifPresent(paiementRepository::delete);

        reservationRepository.delete(reservation);
        log.info("Reservation cancelled: id={}", id);
    }

    // suppression d'une reservation
    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting reservation: {}", id);
        if (!reservationRepository.existsByIdReservation(id)) {
            throw new ResourceNotFoundException("Reservation", "idReservation", id);
        }
        reservationRepository.deleteById(id);
        log.info("Reservation deleted: id={}", id);
    }

    // traitement d'un achat
    @Transactional
    public Map<String, Object> processPurchase(ReservationDTO.PurchaseRequest request) {
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

    // liberation des places en attente expirees
    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void releaseExpiredPendingPlaces() {
        LocalDateTime expiry = LocalDateTime.now().minusMinutes(EXPIRATION_MINUTES);
        List<Place> expired = placeRepository.findExpiredPending(expiry);

        if (!expired.isEmpty()) {
            for (Place place : expired) {
                place.setStatut(StatutPlace.DISPONIBLE);
                place.setDateMiseEnAttente(null);
                placeRepository.save(place);
            }
            log.info("Released {} expired EN_ATTENTE places", expired.size());
        }
    }

    private ReservationDTO toDTO(Reservation reservation) {
        ReservationDTO dto = new ReservationDTO();
        dto.setIdReservation(reservation.getIdReservation());
        dto.setDateReservation(reservation.getDateReservation());
        dto.setCodeClient(reservation.getClient().getCodeUtilisateur());
        dto.setCodeTickets(reservation.getCorrespondances().stream()
                .map(c -> c.getTicket().getCodeTicket())
                .collect(Collectors.toList()));
        return dto;
    }
}
