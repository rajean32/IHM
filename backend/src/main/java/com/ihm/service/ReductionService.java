package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Evenement;
import com.ihm.model.Reduction;
import com.ihm.model.enums.ModeReduction;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.ReductionRepository;
import com.ihm.repository.ReservationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReductionService {

    private static final Logger log = LoggerFactory.getLogger(ReductionService.class);

    private final ReductionRepository reductionRepository;
    private final EvenementRepository evenementRepository;
    private final ReservationRepository reservationRepository;

    public ReductionService(ReductionRepository reductionRepository,
                            EvenementRepository evenementRepository,
                            ReservationRepository reservationRepository) {
        this.reductionRepository = reductionRepository;
        this.evenementRepository = evenementRepository;
        this.reservationRepository = reservationRepository;
    }

    @Transactional(readOnly = true)
    public BigDecimal calculerReduction(String codeClient, Integer idEvenement, BigDecimal montantInitial,
                                         String codePromo, Boolean estEtudiant) {
        BigDecimal reductionTotale = BigDecimal.ZERO;

        if (estEtudiant != null && estEtudiant) {
            BigDecimal reductionEtudiant = montantInitial.multiply(BigDecimal.valueOf(0.10));
            reductionTotale = reductionTotale.add(reductionEtudiant);
            log.debug("Réduction étudiant appliquée: {}", reductionEtudiant);
        }

        if (codePromo != null && !codePromo.isBlank()) {
            Reduction reduction = reductionRepository.findByCode(codePromo).orElse(null);
            if (reduction != null && estValide(reduction, idEvenement)) {
                BigDecimal montantReduit = appliquerReduction(montantInitial, reduction);
                BigDecimal reductionPromo = montantInitial.subtract(montantReduit);
                reductionTotale = reductionTotale.add(reductionPromo);
                log.debug("Réduction code promo appliquée: {}", reductionPromo);
            }
        }

        long nbReservationsClient = reservationRepository.countByClient(codeClient);
        if (nbReservationsClient < 5) {
            BigDecimal reductionPremieres = montantInitial.multiply(BigDecimal.valueOf(0.10));
            reductionTotale = reductionTotale.add(reductionPremieres);
            log.debug("Réduction premières réservations appliquée: {}", reductionPremieres);
        }

        BigDecimal maxReduction = montantInitial.multiply(BigDecimal.valueOf(0.50));
        if (reductionTotale.compareTo(maxReduction) > 0) {
            reductionTotale = maxReduction;
        }

        return reductionTotale;
    }

    private boolean estValide(Reduction reduction, Integer idEvenement) {
        LocalDateTime now = LocalDateTime.now();
        if (reduction.getDateDebut() != null && now.isBefore(reduction.getDateDebut())) return false;
        if (reduction.getDateFin() != null && now.isAfter(reduction.getDateFin())) return false;
        if (reduction.getUtilisationMax() != null && reduction.getUtilisationCount() >= reduction.getUtilisationMax()) return false;
        if (reduction.getEvenement() != null && !reduction.getEvenement().getIdEvenement().equals(idEvenement)) return false;
        return true;
    }

    private BigDecimal appliquerReduction(BigDecimal montant, Reduction reduction) {
        if (reduction.getValeurFixe() != null && reduction.getValeurFixe().compareTo(BigDecimal.ZERO) > 0) {
            return montant.subtract(reduction.getValeurFixe()).max(BigDecimal.ZERO);
        } else if (reduction.getTauxReduction() != null && reduction.getTauxReduction().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal reductionAmount = montant.multiply(reduction.getTauxReduction().divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP));
            return montant.subtract(reductionAmount).max(BigDecimal.ZERO);
        }
        return montant;
    }

    public List<Reduction> getAll() {
        return reductionRepository.findAll();
    }

    public Reduction getById(Long id) {
        return reductionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reduction", "idReduction", id));
    }

    @Transactional
    public Reduction create(Reduction reduction) {
        if (reduction.getCode() != null && reductionRepository.existsByCode(reduction.getCode())) {
            throw new DuplicateResourceException("Reduction", "code", reduction.getCode());
        }
        if (reduction.getEvenement() != null && reduction.getEvenement().getIdEvenement() != null) {
            Evenement event = evenementRepository.findByIdEvenement(reduction.getEvenement().getIdEvenement())
                    .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", reduction.getEvenement().getIdEvenement()));
            reduction.setEvenement(event);
        }
        reduction.setUtilisationCount(0);
        reduction.setActif(true);
        return reductionRepository.save(reduction);
    }

    @Transactional
    public Reduction update(Long id, Reduction reductionDetails) {
        Reduction reduction = getById(id);
        if (reductionDetails.getCode() != null && !reductionDetails.getCode().equals(reduction.getCode())) {
            if (reductionRepository.existsByCode(reductionDetails.getCode())) {
                throw new DuplicateResourceException("Reduction", "code", reductionDetails.getCode());
            }
            reduction.setCode(reductionDetails.getCode());
        }
        if (reductionDetails.getTauxReduction() != null) reduction.setTauxReduction(reductionDetails.getTauxReduction());
        if (reductionDetails.getValeurFixe() != null) reduction.setValeurFixe(reductionDetails.getValeurFixe());
        if (reductionDetails.getDateDebut() != null) reduction.setDateDebut(reductionDetails.getDateDebut());
        if (reductionDetails.getDateFin() != null) reduction.setDateFin(reductionDetails.getDateFin());
        if (reductionDetails.getUtilisationMax() != null) reduction.setUtilisationMax(reductionDetails.getUtilisationMax());
        reduction.setActif(reductionDetails.isActif());
        return reductionRepository.save(reduction);
    }

    @Transactional
    public void delete(Long id) {
        if (!reductionRepository.existsById(id)) {
            throw new ResourceNotFoundException("Reduction", "idReduction", id);
        }
        reductionRepository.deleteById(id);
    }

    @Transactional
    public void incrementUtilisation(String code) {
        reductionRepository.findByCode(code).ifPresent(r -> {
            r.setUtilisationCount(r.getUtilisationCount() + 1);
            reductionRepository.save(r);
        });
    }
}