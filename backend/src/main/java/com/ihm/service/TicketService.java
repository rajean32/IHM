package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.TicketDTO;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TicketService {

    private static final Logger log = LoggerFactory.getLogger(TicketService.class);

    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;
    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;

    public TicketService(TicketRepository ticketRepository,
                         ConcernerRepository concernerRepository,
                         EvenementRepository evenementRepository,
                         PlaceRepository placeRepository) {
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
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

    private TicketDTO toDTO(Ticket ticket) {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket(ticket.getCodeTicket());
        dto.setPrix(ticket.getPrix());
        return dto;
    }
}
