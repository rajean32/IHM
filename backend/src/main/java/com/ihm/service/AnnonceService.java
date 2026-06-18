package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Annonce;
import com.ihm.model.Evenement;
import com.ihm.model.Reservation;
import com.ihm.repository.AnnonceRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.ReservationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AnnonceService {

    private static final Logger log = LoggerFactory.getLogger(AnnonceService.class);

    private final AnnonceRepository annonceRepository;
    private final EvenementRepository evenementRepository;
    private final ReservationRepository reservationRepository;
    private final NotificationService notificationService;

    public AnnonceService(AnnonceRepository annonceRepository,
                          EvenementRepository evenementRepository,
                          ReservationRepository reservationRepository,
                          NotificationService notificationService) {
        this.annonceRepository = annonceRepository;
        this.evenementRepository = evenementRepository;
        this.reservationRepository = reservationRepository;
        this.notificationService = notificationService;
    }

    @Transactional
    public Annonce create(Integer idEvenement, String titre, String message, String codeOrganisateur) {
        Evenement event = evenementRepository.findByIdEvenement(idEvenement)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "id", idEvenement));

        if (!event.getOrganisateur().getCodeUtilisateur().equals(codeOrganisateur)) {
            throw new BadRequestException("Only the event organizer can post announcements");
        }

        Annonce annonce = new Annonce(idEvenement, titre, message, codeOrganisateur);
        Annonce saved = annonceRepository.save(annonce);

        List<Reservation> reservations = reservationRepository.findByEvenementId(idEvenement);
        for (Reservation r : reservations) {
            try {
                notificationService.create(
                    r.getClient().getCodeUtilisateur(),
                    titre,
                    message,
                    "EVENT_ANNOUNCEMENT",
                    String.valueOf(idEvenement)
                );
            } catch (Exception e) {
                log.warn("Failed to notify user {}: {}", r.getClient().getCodeUtilisateur(), e.getMessage());
            }
        }

        log.info("Announcement '{}' created for event {} by {}", titre, idEvenement, codeOrganisateur);
        return saved;
    }

    @Transactional(readOnly = true)
    public List<Annonce> getByEvenement(Integer idEvenement) {
        return annonceRepository.findByIdEvenementOrderByDateCreationDesc(idEvenement);
    }
}
