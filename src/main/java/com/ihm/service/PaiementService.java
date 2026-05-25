package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.PaiementDTO;
import com.ihm.repository.PaiementRepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.schemat.Paiement;
import com.ihm.schemat.Reservation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PaiementService {

    private static final Logger log = LoggerFactory.getLogger(PaiementService.class);

    private final PaiementRepository paiementRepository;
    private final ReservationRepository reservationRepository;

    public PaiementService(PaiementRepository paiementRepository,
                           ReservationRepository reservationRepository) {
        this.paiementRepository = paiementRepository;
        this.reservationRepository = reservationRepository;
    }

    public List<PaiementDTO> getAll() {
        log.debug("Fetching all payments");
        return paiementRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PaiementDTO getById(Integer id) {
        log.debug("Fetching payment by id: {}", id);
        Paiement paiement = paiementRepository.findByIdPaiement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paiement", "idPaiement", id));
        return toDTO(paiement);
    }

    @Transactional
    public PaiementDTO create(PaiementDTO dto) {
        log.debug("Creating payment for reservation: {}", dto.getIdReservation());
        if (paiementRepository.existsByReservation_IdReservation(dto.getIdReservation())) {
            throw new DuplicateResourceException("Paiement", "idReservation", dto.getIdReservation());
        }
        Reservation reservation = reservationRepository.findByIdReservation(dto.getIdReservation())
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", dto.getIdReservation()));
        Paiement paiement = new Paiement();
        paiement.setMontant(dto.getMontant());
        paiement.setDatePaiement(dto.getDatePaiement());
        paiement.setModePaiement(dto.getModePaiement());
        paiement.setReservation(reservation);
        Paiement saved = paiementRepository.save(paiement);
        log.info("Payment created: id={}", saved.getIdPaiement());
        return toDTO(saved);
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting payment: {}", id);
        if (!paiementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Paiement", "idPaiement", id);
        }
        paiementRepository.deleteById(id);
        log.info("Payment deleted: id={}", id);
    }

    private PaiementDTO toDTO(Paiement paiement) {
        PaiementDTO dto = new PaiementDTO();
        dto.setIdPaiement(paiement.getIdPaiement());
        dto.setMontant(paiement.getMontant());
        dto.setDatePaiement(paiement.getDatePaiement());
        dto.setModePaiement(paiement.getModePaiement());
        dto.setIdReservation(paiement.getReservation().getIdReservation());
        return dto;
    }
}
