package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.ReservationDTO;
import com.ihm.schema.ReservationDTO.PurchaseRequest.PurchaseTicketItem;
import com.ihm.repository.*;
import com.ihm.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private static final Logger log = LoggerFactory.getLogger(ReservationService.class);

    private final ReservationRepository reservationRepository;
    private final ClientRepository clientRepository;
    private final TicketRepository ticketRepository;
    private final CorrespondARepository correspondARepository;
    private final PaiementRepository paiementRepository;
    private final ConcernerRepository concernerRepository;
    private final PlaceRepository placeRepository;
    private final EvenementRepository evenementRepository;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final TicketService ticketService;

    public ReservationService(ReservationRepository reservationRepository,
                              ClientRepository clientRepository,
                              TicketRepository ticketRepository,
                              CorrespondARepository correspondARepository,
                              PaiementRepository paiementRepository,
                              ConcernerRepository concernerRepository,
                              PlaceRepository placeRepository,
                              EvenementRepository evenementRepository,
                              EvenementPlaceConfigurationRepository configRepository,
                              TicketService ticketService) {
        this.reservationRepository = reservationRepository;
        this.clientRepository = clientRepository;
        this.ticketRepository = ticketRepository;
        this.correspondARepository = correspondARepository;
        this.paiementRepository = paiementRepository;
        this.concernerRepository = concernerRepository;
        this.placeRepository = placeRepository;
        this.evenementRepository = evenementRepository;
        this.configRepository = configRepository;
        this.ticketService = ticketService;
    }

    @Transactional(readOnly = true)
    public List<ReservationDTO> getAll() {
        log.debug("Fetching all reservations");
        return reservationRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ReservationDTO getById(Integer id) {
        log.debug("Fetching reservation by id: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));
        return toDTO(reservation);
    }

    @Transactional(readOnly = true)
    public List<ReservationDTO> getByClient(String codeClient) {
        log.debug("Fetching reservations by client: {}", codeClient);
        return reservationRepository.findByClient_CodeUtilisateur(codeClient)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

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
                List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
                for (Concerner c : concerners) {
                    Evenement event = c.getEvenement();
                    if (event.getDateEvenement() != null && event.getDateEvenement().isBefore(LocalDate.now())) {
                        throw new BadRequestException("Cannot reserve: event '" + event.getTitre() + "' is already finished");
                    }
                    if ("termine".equals(event.getStatut()) || "annule".equals(event.getStatut())) {
                        throw new BadRequestException("Cannot reserve: event '" + event.getTitre() + "' is " + event.getStatut());
                    }
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

    @Transactional
    public void cancel(Integer id) {
        log.debug("Cancelling reservation: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));

        List<CorrespondA> correspondances = correspondARepository.findByReservation_IdReservation(id);
        for (CorrespondA ca : correspondances) {
            List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
            for (Concerner c : concerners) {
                EvenementPlaceConfiguration config = configRepository
                        .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                                c.getEvenement().getIdEvenement(), c.getPlace().getNumeroPlace())
                        .orElse(null);
                if (config != null) {
                    config.setStatut("DISPONIBLE");
                    configRepository.save(config);
                }
            }
        }

        correspondances.forEach(correspondARepository::delete);

        paiementRepository.findByReservation_IdReservation(id).ifPresent(paiementRepository::delete);

        reservationRepository.delete(reservation);
        log.info("Reservation cancelled: id={}", id);
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting reservation: {}", id);
        if (!reservationRepository.existsByIdReservation(id)) {
            throw new ResourceNotFoundException("Reservation", "idReservation", id);
        }
        reservationRepository.deleteById(id);
        log.info("Reservation deleted: id={}", id);
    }

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

        for (PurchaseTicketItem item : request.getTickets()) {
            if (item.getIdEvenement() != null) {
                Evenement event = evenementRepository.findByIdEvenement(item.getIdEvenement())
                        .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", item.getIdEvenement()));
                if (event.getDateEvenement() != null && event.getDateEvenement().isBefore(LocalDate.now())) {
                    throw new BadRequestException("Cannot purchase: event '" + event.getTitre() + "' is already finished");
                }
                if ("termine".equals(event.getStatut()) || "annule".equals(event.getStatut())) {
                    throw new BadRequestException("Cannot purchase: event '" + event.getTitre() + "' is " + event.getStatut());
                }
            }
        }

        List<Ticket> tickets = new ArrayList<>();
        for (PurchaseTicketItem item : request.getTickets()) {
            Ticket ticket = new Ticket();
            ticket.setCodeTicket(item.getCodeTicket());
            ticket.setPrix(item.getPrix() != null ? item.getPrix() : BigDecimal.ZERO);
            Ticket saved = ticketRepository.save(ticket);
            tickets.add(saved);

            if (item.getIdEvenement() != null && item.getNumeroPlace() != null) {
                Place place = placeRepository.findByNumeroPlace(item.getNumeroPlace())
                        .orElse(null);
                if (place != null) {
                    ConcernerId concernerId = new ConcernerId(item.getIdEvenement(), item.getCodeTicket(), item.getNumeroPlace());
                    Concerner concerner = new Concerner();
                    concerner.setId(concernerId);
                    concerner.setEvenement(evenementRepository.findByIdEvenement(item.getIdEvenement())
                            .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", item.getIdEvenement())));
                    concerner.setTicket(saved);
                    concerner.setPlace(place);
                    concernerRepository.save(concerner);

                    EvenementPlaceConfiguration config = configRepository
                            .findByEvenement_IdEvenementAndPlace_NumeroPlace(item.getIdEvenement(), item.getNumeroPlace())
                            .orElse(null);
                    if (config != null) {
                        config.setStatut("RESERVEE");
                        configRepository.save(config);
                    }
                }
            }
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

    private ReservationDTO toDTO(Reservation reservation) {
        ReservationDTO dto = new ReservationDTO();
        dto.setIdReservation(reservation.getIdReservation());
        dto.setDateReservation(reservation.getDateReservation());
        dto.setCodeClient(reservation.getClient().getCodeUtilisateur());
        dto.setCodeTickets(reservation.getCorrespondances().stream()
                .map(c -> c.getTicket().getCodeTicket())
                .collect(Collectors.toList()));
        dto.setTickets(reservation.getCorrespondances().stream()
                .map(c -> ticketService.toDTO(c.getTicket()))
                .collect(Collectors.toList()));
        return dto;
    }
}
