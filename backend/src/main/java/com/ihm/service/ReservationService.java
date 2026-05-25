package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.ReservationDTO;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private static final Logger log = LoggerFactory.getLogger(ReservationService.class);

    private final ReservationRepository reservationRepository;
    private final ClientRepository clientRepository;
    private final TicketRepository ticketRepository;
    private final CorrespondARepository correspondARepository;

    public ReservationService(ReservationRepository reservationRepository,
                              ClientRepository clientRepository,
                              TicketRepository ticketRepository,
                              CorrespondARepository correspondARepository) {
        this.reservationRepository = reservationRepository;
        this.clientRepository = clientRepository;
        this.ticketRepository = ticketRepository;
        this.correspondARepository = correspondARepository;
    }

    public List<ReservationDTO> getAll() {
        log.debug("Fetching all reservations");
        return reservationRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public ReservationDTO getById(Integer id) {
        log.debug("Fetching reservation by id: {}", id);
        Reservation reservation = reservationRepository.findByIdReservation(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", id));
        return toDTO(reservation);
    }

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
    public void delete(Integer id) {
        log.debug("Deleting reservation: {}", id);
        if (!reservationRepository.existsByIdReservation(id)) {
            throw new ResourceNotFoundException("Reservation", "idReservation", id);
        }
        reservationRepository.deleteById(id);
        log.info("Reservation deleted: id={}", id);
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
