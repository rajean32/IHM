package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.PaiementDTO;
import com.ihm.repository.PaiementRepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.model.Paiement;
import com.ihm.model.Reservation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
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

    // recuperation de tous les paiements
    public List<PaiementDTO> getAll() {
        log.debug("Fetching all payments");
        return paiementRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // paiements d'un client
    public List<PaiementDTO> getByClient(String codeClient) {
        log.debug("Fetching payments by client: {}", codeClient);
        return paiementRepository.findByClient(codeClient)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un paiement par son id
    public PaiementDTO getById(Integer id) {
        log.debug("Fetching payment by id: {}", id);
        Paiement paiement = paiementRepository.findByIdPaiement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paiement", "idPaiement", id));
        return toDTO(paiement);
    }

    // creation d'un paiement
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

    // mise a jour d'un paiement
    @Transactional
    public PaiementDTO update(Integer id, PaiementDTO dto) {
        log.debug("Updating payment: {}", id);
        Paiement paiement = paiementRepository.findByIdPaiement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paiement", "idPaiement", id));

        if (dto.getMontant() != null) paiement.setMontant(dto.getMontant());
        if (dto.getModePaiement() != null) paiement.setModePaiement(dto.getModePaiement());
        if (dto.getDatePaiement() != null) paiement.setDatePaiement(dto.getDatePaiement());

        Paiement saved = paiementRepository.save(paiement);
        log.info("Payment updated: id={}", id);
        return toDTO(saved);
    }

    // traitement webhook de paiement
    @Transactional
    public PaiementDTO.PaiementStatus processWebhook(String reservationId, BigDecimal amount, String modePaiement, String status) {
        log.debug("Processing payment webhook for reservation: {}", reservationId);
        Integer idReservation = Integer.parseInt(reservationId);

        if ("SUCCESS".equalsIgnoreCase(status)) {
            if (!paiementRepository.existsByReservation_IdReservation(idReservation)) {
                Reservation reservation = reservationRepository.findByIdReservation(idReservation)
                        .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", idReservation));

                Paiement paiement = new Paiement();
                paiement.setMontant(amount);
                paiement.setDatePaiement(LocalDateTime.now());
                paiement.setModePaiement(modePaiement);
                paiement.setReservation(reservation);
                paiementRepository.save(paiement);
                log.info("Payment created via webhook for reservation: {}", idReservation);
            }

            Paiement paiement = paiementRepository.findByReservation_IdReservation(idReservation).orElse(null);
            PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
            response.setIdPaiement(paiement != null ? paiement.getIdPaiement() : null);
            response.setIdReservation(idReservation);
            response.setMontant(amount);
            response.setModePaiement(modePaiement);
            response.setDatePaiement(paiement != null ? paiement.getDatePaiement() : LocalDateTime.now());
            response.setStatus("CONFIRMED");
            return response;
        } else {
            PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
            response.setIdReservation(idReservation);
            response.setMontant(amount);
            response.setModePaiement(modePaiement);
            response.setStatus("FAILED");
            return response;
        }
    }

    // statut d'un paiement
    public PaiementDTO.PaiementStatus getPaymentStatus(Integer idReservation) {
        log.debug("Fetching payment status for reservation: {}", idReservation);
        Paiement paiement = paiementRepository.findByReservation_IdReservation(idReservation)
                .orElse(null);

        PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
        if (paiement != null) {
            response.setIdPaiement(paiement.getIdPaiement());
            response.setIdReservation(idReservation);
            response.setMontant(paiement.getMontant());
            response.setModePaiement(paiement.getModePaiement());
            response.setDatePaiement(paiement.getDatePaiement());
            response.setStatus("PAID");
        } else {
            response.setIdReservation(idReservation);
            response.setStatus("PENDING");
        }
        return response;
    }

    // suppression d'un paiement
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
