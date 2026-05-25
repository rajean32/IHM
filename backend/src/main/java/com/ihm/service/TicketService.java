package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.TicketDTO;
import com.ihm.model.dto.TicketQRResponse;
import com.ihm.model.dto.TicketValidationResponse;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    public TicketService(TicketRepository ticketRepository,
                         ConcernerRepository concernerRepository,
                         EvenementRepository evenementRepository,
                         PlaceRepository placeRepository,
                         CorrespondARepository correspondARepository,
                         QRCodeService qrCodeService) {
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.correspondARepository = correspondARepository;
        this.qrCodeService = qrCodeService;
    }

    public List<TicketDTO> getAll() {
        log.debug("Fetching all tickets");
        return ticketRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public TicketDTO getById(String code) {
        log.debug("Fetching ticket by code: {}", code);
        Ticket ticket = ticketRepository.findByCodeTicket(code)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", code));
        return toDTO(ticket);
    }

    @Transactional
    public TicketDTO create(TicketDTO dto) {
        log.debug("Creating ticket: {}", dto.getCodeTicket());
        if (ticketRepository.existsByCodeTicket(dto.getCodeTicket())) {
            throw new DuplicateResourceException("Ticket", "codeTicket", dto.getCodeTicket());
        }
        Ticket ticket = new Ticket();
        ticket.setCodeTicket(dto.getCodeTicket());
        ticket.setPrix(dto.getPrix());
        Ticket saved = ticketRepository.save(ticket);

        if (dto.getIdEvenement() != null && dto.getNumeroPlace() != null) {
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
        ticketRepository.deleteById(code);
        log.info("Ticket deleted: {}", code);
    }

    public TicketQRResponse generateQRCode(String codeTicket) {
        log.debug("Generating QR code for ticket: {}", codeTicket);
        Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
        String evenementTitre = "";
        String placeNumero = "";
        String rang = "";
        String typePlace = "";

        if (!concerners.isEmpty()) {
            Concerner concerner = concerners.get(0);
            evenementTitre = concerner.getEvenement().getTitre();
            placeNumero = concerner.getPlace().getNumeroPlace();
            rang = concerner.getPlace().getRange() != null ? concerner.getPlace().getRange() : "";
            typePlace = concerner.getPlace().getTypePlace() != null ? concerner.getPlace().getTypePlace() : "";
        }

        String ticketData = qrCodeService.generateTicketData(codeTicket, evenementTitre, placeNumero);
        String qrBase64 = qrCodeService.generateQRCodeBase64(ticketData);

        TicketQRResponse response = new TicketQRResponse();
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

    public TicketValidationResponse validateTicket(String codeTicket) {
        log.debug("Validating ticket: {}", codeTicket);
        Ticket ticket = ticketRepository.findByCodeTicket(codeTicket)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket", "codeTicket", codeTicket));

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(codeTicket);
        if (concerners.isEmpty()) {
            TicketValidationResponse response = new TicketValidationResponse();
            response.setValid(false);
            response.setCodeTicket(codeTicket);
            response.setMessage("Ticket not linked to any event");
            return response;
        }

        Concerner concerner = concerners.get(0);
        List<CorrespondA> correspondances = correspondARepository.findByTicket_CodeTicket(codeTicket);

        if (correspondances.isEmpty()) {
            TicketValidationResponse response = new TicketValidationResponse();
            response.setValid(false);
            response.setCodeTicket(codeTicket);
            response.setMessage("Ticket not used in any reservation");
            return response;
        }

        String clientNom = correspondances.get(0).getReservation().getClient().getNom() + " " +
                correspondances.get(0).getReservation().getClient().getPrenoms();

        TicketValidationResponse response = new TicketValidationResponse();
        response.setValid(true);
        response.setCodeTicket(codeTicket);
        response.setEvenementTitre(concerner.getEvenement().getTitre());
        response.setPlaceNumero(concerner.getPlace().getNumeroPlace());
        response.setClientNom(clientNom);
        response.setMessage("Ticket is valid");

        return response;
    }

    private TicketDTO toDTO(Ticket ticket) {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket(ticket.getCodeTicket());
        dto.setPrix(ticket.getPrix());

        List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ticket.getCodeTicket());
        if (!concerners.isEmpty()) {
            Concerner c = concerners.get(0);
            dto.setIdEvenement(c.getEvenement().getIdEvenement());
            dto.setNumeroPlace(c.getPlace().getNumeroPlace());
        }

        return dto;
    }
}
