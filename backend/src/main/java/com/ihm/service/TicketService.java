package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.TicketDTO;
import com.ihm.repository.*;
import com.ihm.model.*;
import com.ihm.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class TicketService {

    private static final Logger log = LoggerFactory.getLogger(TicketService.class);

    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;
    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final CorrespondARepository correspondARepository;
    private final QRCodeService qrCodeService;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final StandingZoneService standingZoneService;
    private final ZoneStandingRepository zoneStandingRepository;
    private final NotificationService notificationService;
    private final ActionLogService actionLogService;

    public TicketService(TicketRepository ticketRepository,
                         ConcernerRepository concernerRepository,
                         EvenementRepository evenementRepository,
                         PlaceRepository placeRepository,
                         CorrespondARepository correspondARepository,
                         QRCodeService qrCodeService,
                         EvenementPlaceConfigurationRepository configRepository,
                         StandingZoneService standingZoneService,
                         ZoneStandingRepository zoneStandingRepository,
                         NotificationService notificationService,
                         ActionLogService actionLogService) {
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.correspondARepository = correspondARepository;
        this.qrCodeService = qrCodeService;
        this.configRepository = configRepository;
        this.standingZoneService = standingZoneService;
        this.zoneStandingRepository = zoneStandingRepository;
        this.notificationService = notificationService;
        this.actionLogService = actionLogService;
    }

    @Transactional(readOnly = true)
    public List<TicketDTO> getAll() {
        log.debug("Fetching all tickets");
        return ticketRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<TicketDTO> getByClient(String clientCode) {
        log.debug("Fetching tickets for client: {}", clientCode);
        return ticketRepository.findByCorrespondances_Reservation_Client_CodeUtilisateur(clientCode)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TicketDTO getById(String code) {
        log.debug("Fetching ticket by code: {}", code);
        Ticket ticket = ticketRepository.findByCodeTicket(code)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", code));
        return toDTO(ticket);
    }

    @Transactional(readOnly = true)
    public TicketDTO.ValidationResponse validateTicket(String codeTicket) {
        log.debug("Validating ticket: {}", codeTicket);
        Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

        List<CorrespondA> correspondances = correspondARepository.findByTicket_CodeTicket(codeTicket);

        if (correspondances.isEmpty()) {
            TicketDTO.ValidationResponse response = new TicketDTO.ValidationResponse();
            response.setValid(false);
            response.setCodeTicket(codeTicket);
            response.setMessage("Ticket not used in any reservation");
            return response;
        }

        TicketDTO.ValidationResponse response = new TicketDTO.ValidationResponse();
        response.setValid(true);
        response.setCodeTicket(codeTicket);
        response.setClientNom(correspondances.get(0).getReservation().getClient().getNom() + " " +
                correspondances.get(0).getReservation().getClient().getPrenoms());
        response.setMessage("Ticket is valid");

        if (ticket.getZoneStanding() != null) {
            response.setEvenementTitre(ticket.getZoneStanding().getEvenement().getTitre());
            response.setPlaceNumero(ticket.getZoneStanding().getNom());
        } else {
            List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
            if (!concerners.isEmpty()) {
                Concerner concerner = concerners.get(0);
                response.setEvenementTitre(concerner.getEvenement().getTitre());
                response.setPlaceNumero(concerner.getPlace().getNumeroPlace());
            }
        }

        return response;
    }

    @Transactional
    public TicketDTO create(TicketDTO dto) {
        log.debug("Creating ticket: {}", dto.getCodeTicket());
        if (ticketRepository.existsByCodeTicket(dto.getCodeTicket())) {
            throw new DuplicateResourceException("Ticket", "codeTicket", dto.getCodeTicket());
        }

        if (dto.getIdEvenement() != null) {
            Evenement event = evenementRepository.findByIdEvenement(dto.getIdEvenement())
                    .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", dto.getIdEvenement()));
            if (event.getDateEvenement() != null && event.getDateEvenement().isBefore(LocalDate.now())) {
                throw new BadRequestException("Cannot create ticket: event '" + event.getTitre() + "' is already finished");
            }
            if ("termine".equals(event.getStatut()) || "annule".equals(event.getStatut())) {
                throw new BadRequestException("Cannot create ticket: event '" + event.getTitre() + "' is " + event.getStatut());
            }
        }

        Ticket ticket = new Ticket();
        ticket.setCodeTicket(dto.getCodeTicket());
        ticket.setPrix(dto.getPrix());

        if (dto.getIdEvenement() != null) {
            Evenement event = evenementRepository.findByIdEvenement(dto.getIdEvenement())
                    .orElse(null);
            ticket.setEvenement(event);
        }

        if (dto.getIdZone() != null) {
            ZoneStanding zone = zoneStandingRepository.findById(dto.getIdZone())
                    .orElseThrow(() -> new ResourceNotFoundException("ZoneStanding", "idZone", dto.getIdZone()));
            standingZoneService.incrementReservation(dto.getIdZone());
            ticket.setZoneStanding(zone);
        }

        Ticket saved = ticketRepository.save(ticket);

        if (dto.getIdEvenement() != null && dto.getNumeroPlace() != null) {
            if (concernerRepository.existsByEvenement_IdEvenementAndPlace_NumeroPlace(
                    dto.getIdEvenement(), dto.getNumeroPlace())) {
                throw new BadRequestException("Place " + dto.getNumeroPlace()
                        + " is already reserved for this event");
            }
            Evenement event = evenementRepository.findByIdEvenement(dto.getIdEvenement())
                    .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", dto.getIdEvenement()));
            Place place = placeRepository.findByNumeroPlace(dto.getNumeroPlace())
                    .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", dto.getNumeroPlace()));

            ConcernerId concernerId = new ConcernerId(dto.getIdEvenement(), dto.getCodeTicket(), dto.getNumeroPlace());
            Concerner concerner = new Concerner();
            concerner.setId(concernerId);
            concerner.setEvenement(event);
            concerner.setTicket(saved);
            concerner.setPlace(place);
            concernerRepository.save(concerner);

            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(dto.getIdEvenement(), dto.getNumeroPlace())
                    .orElseThrow(() -> new ResourceNotFoundException("EvenementPlaceConfiguration",
                            "event+place", dto.getIdEvenement() + "+" + dto.getNumeroPlace()));
            config.setStatut("RESERVEE");
            configRepository.save(config);

            log.info("Concerner created for ticket {} and place {} (status: RESERVEE)", dto.getCodeTicket(), dto.getNumeroPlace());
        }

        log.info("Ticket created: {}", saved.getCodeTicket());
        return toDTO(saved);
    }

    @Transactional
    public TicketDTO update(String code, TicketDTO dto) {
        log.debug("Updating ticket: {}", code);
        Ticket ticket = ticketRepository.findByCodeTicket(code)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", code));
        if (dto.getPrix() != null) ticket.setPrix(dto.getPrix());
        Ticket saved = ticketRepository.save(ticket);
        log.info("Ticket updated: {}", code);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting ticket: {}", code);
        if (!ticketRepository.existsByCodeTicket(code)) {
            throw new ResourceNotFoundException("Ticket", "codeTicket", code);
        }

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(code);
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

        ticketRepository.deleteById(code);
        log.info("Ticket deleted: {}", code);
    }

    @Transactional(readOnly = true)
    public TicketDTO.QRResponse generateQRCode(String codeTicket) {
        log.debug("Generating QR code for ticket: {}", codeTicket);
        Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
        String evenementTitre = null;
        String placeNumero = ticket.getZoneStanding() != null ? ticket.getZoneStanding().getNom() : null;
        String rang = null;
        String typePlace = ticket.getZoneStanding() != null ? "DEBOUT" : null;

        if (ticket.getZoneStanding() != null) {
            evenementTitre = ticket.getZoneStanding().getEvenement().getTitre();
            placeNumero = ticket.getZoneStanding().getNom();
        } else if (!concerners.isEmpty()) {
            Concerner concerner = concerners.get(0);
            evenementTitre = concerner.getEvenement().getTitre();
            placeNumero = concerner.getPlace().getNumeroPlace();

            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                            concerner.getEvenement().getIdEvenement(), placeNumero)
                    .orElse(null);
            if (config != null) {
                rang = config.getRange();
                typePlace = config.getTypePlace();
            }
        }

        if ((evenementTitre == null || evenementTitre.isEmpty()) && ticket.getEvenement() != null) {
            evenementTitre = ticket.getEvenement().getTitre();
        }

        String ticketData = qrCodeService.generateTicketData(codeTicket, evenementTitre, placeNumero);
        String qrBase64 = qrCodeService.generateQRCodeBase64(ticketData);

        TicketDTO.QRResponse response = new TicketDTO.QRResponse();
        response.setCodeTicket(codeTicket);
        response.setQrCodeBase64(qrBase64);
        response.setEvenementTitre(evenementTitre);
        response.setPlaceNumero(placeNumero);
        response.setRang(rang);
        response.setTypePlace(typePlace);
        response.setPrix(ticket.getPrix() != null ? ticket.getPrix().toString() : "0.00");
        response.setStatus("VALID");

        return response;
    }

    @Transactional
    public TicketDTO.GateScanResponse scanAtGate(String qrToken) {
        log.debug("Gate scan for token: {}", qrToken);

        Ticket ticket = ticketRepository.findByCodeTicket(qrToken).orElse(null);
        if (ticket == null) {
            TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
            r.setStatut("INVALID");
            r.setMessage("Ticket not found");
            return r;
        }

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(qrToken);
        List<CorrespondA> correspondances = correspondARepository.findByTicket_CodeTicket(qrToken);

        if (ticket.getZoneStanding() == null && concerners.isEmpty()) {
            actionLogService.logFraud("STAFF", "TICKET_SCAN_FAILED", "Ticket", qrToken,
                    "Ticket not linked to any event or standing zone");
            TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
            r.setStatut("INVALID");
            r.setMessage("Ticket not linked to any event");
            return r;
        }

        if (ticket.getZoneStanding() != null) {
            String clientNom2 = correspondances.isEmpty() ? "" :
                    correspondances.get(0).getReservation().getClient().getNom() + " "
                    + correspondances.get(0).getReservation().getClient().getPrenoms();

            String orgCode2 = ticket.getZoneStanding().getEvenement().getOrganisateur().getCodeUtilisateur();
            notificationService.create(
                    orgCode2,
                    "Ticket validé (debout)",
                    "Le ticket " + qrToken + " (zone " + ticket.getZoneStanding().getNom() + ") a été validé à l'entrée.",
                    "TICKET_VALIDATED",
                    qrToken
            );

            TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
            r.setStatut("VALID");
            r.setMessage("Ticket validated successfully (standing)");
            r.setCodeTicket(qrToken);
            r.setEvenementTitre(ticket.getZoneStanding().getEvenement().getTitre());
            r.setPlaceNumero(ticket.getZoneStanding().getNom());
            r.setClientNom(clientNom2);
            return r;
        }

        if (correspondances.isEmpty()) {
            actionLogService.logFraud("STAFF", "TICKET_SCAN_FAILED", "Ticket", qrToken,
                    "Ticket not linked to any reservation");
            TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
            r.setStatut("INVALID");
            r.setMessage("Ticket not linked to any reservation");
            return r;
        }

        Concerner concerner = concerners.get(0);
        EvenementPlaceConfiguration config = configRepository
                .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                        concerner.getEvenement().getIdEvenement(), concerner.getPlace().getNumeroPlace())
                .orElse(null);

        if (config != null && "UTILISE".equals(config.getStatut())) {
            actionLogService.logFraud("STAFF", "TICKET_SCAN_FAILED", "Ticket", qrToken,
                    "Ticket already used for place " + concerner.getPlace().getNumeroPlace());
            String orgCode3 = concerner.getEvenement().getOrganisateur().getCodeUtilisateur();
            notificationService.create(
                    orgCode3,
                    "Ticket déjà utilisé",
                    "Le ticket " + qrToken + " (" + concerner.getEvenement().getTitre() + ") a déjà été scanné.",
                    "TICKET_ALREADY_USED",
                    qrToken
            );

            TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
            r.setStatut("ALREADY_USED");
            r.setMessage("Ticket has already been used");
            r.setCodeTicket(qrToken);
            r.setEvenementTitre(concerner.getEvenement().getTitre());
            r.setPlaceNumero(concerner.getPlace().getNumeroPlace());
            return r;
        }

        // Feature 19: Double validation — verify place matches event config
        if (config != null && concerner.getPlace() != null) {
            String scannedPlace = concerner.getPlace().getNumeroPlace();
            EvenementPlaceConfiguration matchedConfig = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                            concerner.getEvenement().getIdEvenement(), scannedPlace)
                    .orElse(null);
            if (matchedConfig == null) {
                actionLogService.logFraud("STAFF", "TICKET_SCAN_FAILED", "Ticket", qrToken,
                        "Place " + scannedPlace + " not found in event config");
                TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
                r.setStatut("INVALID");
                r.setMessage("Place " + scannedPlace + " does not match event configuration");
                r.setCodeTicket(qrToken);
                r.setPlaceNumero(scannedPlace);
                return r;
            }
            if ("RESERVEE".equals(matchedConfig.getStatut()) || "DISPONIBLE".equals(matchedConfig.getStatut())) {
                matchedConfig.setStatut("UTILISE");
                configRepository.save(matchedConfig);
                log.info("Ticket {} marked as UTILISE at gate (place: {})", qrToken, scannedPlace);
            }
        } else if (config != null) {
            config.setStatut("UTILISE");
            configRepository.save(config);
            log.info("Ticket {} marked as UTILISE at gate", qrToken);
        }

        String clientNom = correspondances.get(0).getReservation().getClient().getNom() + " "
                + correspondances.get(0).getReservation().getClient().getPrenoms();

        String orgCode = concerner.getEvenement().getOrganisateur().getCodeUtilisateur();
        notificationService.create(
                orgCode,
                "Ticket validé",
                "Le ticket " + qrToken + " (" + clientNom + ") a été validé à l'entrée pour \"" + concerner.getEvenement().getTitre() + "\".",
                "TICKET_VALIDATED",
                qrToken
        );

        TicketDTO.GateScanResponse r = new TicketDTO.GateScanResponse();
        r.setStatut("VALID");
        r.setMessage("Ticket validated successfully");
        r.setCodeTicket(qrToken);
        r.setEvenementTitre(concerner.getEvenement().getTitre());
        r.setPlaceNumero(concerner.getPlace().getNumeroPlace());
        r.setClientNom(clientNom);
        return r;
    }

    @Transactional(readOnly = true)
    public List<String> getValidTicketCodesForEvent(Integer eventId) {
        return ticketRepository.findValidCodesByEvent(eventId);
    }

    public TicketDTO toDTO(Ticket ticket) {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket(ticket.getCodeTicket());
        dto.setPrix(ticket.getPrix());

        if (ticket.getZoneStanding() != null) {
            dto.setZoneNom(ticket.getZoneStanding().getNom());
            dto.setNumeroPlace(ticket.getZoneStanding().getNom());
            dto.setIdEvenement(ticket.getZoneStanding().getEvenement().getIdEvenement());
            dto.setEvenementTitre(ticket.getZoneStanding().getEvenement().getTitre());
            dto.setTypePlace("DEBOUT");
            if (ticket.getZoneStanding().getEvenement().getDateEvenement() != null)
                dto.setDateEvenement(ticket.getZoneStanding().getEvenement().getDateEvenement().toString());
            if (ticket.getZoneStanding().getEvenement().getHeureEvenement() != null)
                dto.setHeureEvenement(ticket.getZoneStanding().getEvenement().getHeureEvenement().toString());
            dto.setImage(ImageUtils.toDataUrl(ticket.getZoneStanding().getEvenement().getImage()));
            dto.setStatut("VALID");
            return dto;
        }

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ticket.getCodeTicket());
        if (!concerners.isEmpty()) {
            Concerner c = concerners.get(0);
            dto.setIdEvenement(c.getEvenement().getIdEvenement());
            dto.setNumeroPlace(c.getPlace().getNumeroPlace());
            dto.setEvenementTitre(c.getEvenement().getTitre());
            if (c.getEvenement().getDateEvenement() != null)
                dto.setDateEvenement(c.getEvenement().getDateEvenement().toString());
            if (c.getEvenement().getHeureEvenement() != null)
                dto.setHeureEvenement(c.getEvenement().getHeureEvenement().toString());
            if (c.getPlace().getSalle() != null) {
                dto.setSalleNom(c.getPlace().getSalle().getNomSalle());
                if (c.getPlace().getSalle().getLieu() != null) {
                    dto.setLieuNom(c.getPlace().getSalle().getLieu().getNomLieu());
                }
            }

            dto.setImage(ImageUtils.toDataUrl(c.getEvenement().getImage()));

            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                            c.getEvenement().getIdEvenement(), c.getPlace().getNumeroPlace())
                    .orElse(null);
            if (config != null) {
                dto.setRang(config.getRange());
                dto.setTypePlace(config.getTypePlace());
                dto.setStatut(config.getStatut());
            }
        }

    // Fallback 1: try to get event info via sibling tickets in the same reservation
    if (dto.getEvenementTitre() == null) {
        fillFromReservationFallback(dto, ticket);
    }

    // Fallback 2: use ticket's direct evenement reference
    if (dto.getEvenementTitre() == null && ticket.getEvenement() != null) {
        Evenement e = ticket.getEvenement();
        dto.setIdEvenement(e.getIdEvenement());
        dto.setEvenementTitre(e.getTitre());
        if (e.getDateEvenement() != null)
            dto.setDateEvenement(e.getDateEvenement().toString());
        if (e.getHeureEvenement() != null)
            dto.setHeureEvenement(e.getHeureEvenement().toString());
        dto.setImage(ImageUtils.toDataUrl(e.getImage()));
        dto.setStatut("VALID");
    }

    return dto;
    }

    private void fillFromReservationFallback(TicketDTO dto, Ticket ticket) {
        List<CorrespondA> correspondances = correspondARepository.findByTicket_CodeTicket(ticket.getCodeTicket());
        for (CorrespondA ca : correspondances) {
            Reservation reservation = ca.getReservation();
            List<CorrespondA> siblings = correspondARepository.findByReservation_IdReservation(reservation.getIdReservation());
            for (CorrespondA sibling : siblings) {
                if (sibling.getTicket().getCodeTicket().equals(ticket.getCodeTicket())) continue;
                Ticket siblingTicket = sibling.getTicket();

                if (siblingTicket.getZoneStanding() != null) {
                    dto.setZoneNom(siblingTicket.getZoneStanding().getNom());
                    dto.setIdEvenement(siblingTicket.getZoneStanding().getEvenement().getIdEvenement());
                    dto.setEvenementTitre(siblingTicket.getZoneStanding().getEvenement().getTitre());
                    if (siblingTicket.getZoneStanding().getEvenement().getDateEvenement() != null)
                        dto.setDateEvenement(siblingTicket.getZoneStanding().getEvenement().getDateEvenement().toString());
                    if (siblingTicket.getZoneStanding().getEvenement().getHeureEvenement() != null)
                        dto.setHeureEvenement(siblingTicket.getZoneStanding().getEvenement().getHeureEvenement().toString());
                    dto.setImage(ImageUtils.toDataUrl(siblingTicket.getZoneStanding().getEvenement().getImage()));
                    dto.setStatut("VALID");
                    return;
                }

                List<Concerner> siblingConcerners = concernerRepository.findByTicket_CodeTicket(siblingTicket.getCodeTicket());
                if (!siblingConcerners.isEmpty()) {
                    Concerner c = siblingConcerners.get(0);
                    dto.setIdEvenement(c.getEvenement().getIdEvenement());
                    dto.setEvenementTitre(c.getEvenement().getTitre());
                    dto.setNumeroPlace(c.getPlace().getNumeroPlace());
                    if (c.getEvenement().getDateEvenement() != null)
                        dto.setDateEvenement(c.getEvenement().getDateEvenement().toString());
                    if (c.getEvenement().getHeureEvenement() != null)
                        dto.setHeureEvenement(c.getEvenement().getHeureEvenement().toString());
                    if (c.getPlace().getSalle() != null) {
                        dto.setSalleNom(c.getPlace().getSalle().getNomSalle());
                        if (c.getPlace().getSalle().getLieu() != null) {
                            dto.setLieuNom(c.getPlace().getSalle().getLieu().getNomLieu());
                        }
                    }
                    dto.setImage(ImageUtils.toDataUrl(c.getEvenement().getImage()));
                    EvenementPlaceConfiguration config = configRepository
                            .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                                    c.getEvenement().getIdEvenement(), c.getPlace().getNumeroPlace())
                            .orElse(null);
                    if (config != null) {
                        dto.setRang(config.getRange());
                        dto.setTypePlace(config.getTypePlace());
                    }
                    return;
                }
            }
        }
    }
}
