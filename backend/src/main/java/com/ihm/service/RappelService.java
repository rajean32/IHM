package com.ihm.service;

import com.ihm.model.Evenement;
import com.ihm.model.Reservation;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.ReservationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class RappelService {

    private static final Logger log = LoggerFactory.getLogger(RappelService.class);

    private final EvenementRepository evenementRepository;
    private final ReservationRepository reservationRepository;
    private final NotificationService notificationService;

    public RappelService(EvenementRepository evenementRepository,
                         ReservationRepository reservationRepository,
                         NotificationService notificationService) {
        this.evenementRepository = evenementRepository;
        this.reservationRepository = reservationRepository;
        this.notificationService = notificationService;
    }

    @Transactional
    @Scheduled(cron = "0 0 8 * * *")
    public void rappelJ1() {
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        log.info("Rappel J-1: checking events on {}", tomorrow);
        List<Evenement> events = evenementRepository.findByDateEvenementBetween(tomorrow, tomorrow);
        int rappels = 0;
        for (Evenement event : events) {
            List<Reservation> reservations = reservationRepository.findByEvenementId(event.getIdEvenement());
            for (Reservation r : reservations) {
                try {
                    notificationService.create(
                        r.getClient().getCodeUtilisateur(),
                        "Rappel: Événement demain",
                        "N'oubliez pas votre événement \"" + event.getTitre() + "\" demain !",
                        "EVENT_REMINDER",
                        String.valueOf(event.getIdEvenement())
                    );
                    rappels++;
                } catch (Exception e) {
                    log.warn("Failed to remind user {}: {}", r.getClient().getCodeUtilisateur(), e.getMessage());
                }
            }
        }
        if (rappels > 0) log.info("Rappel J-1: {} notification(s) envoyée(s)", rappels);
    }

    @Transactional
    @Scheduled(cron = "0 0 9 * * MON")
    public void digestHebdomadaire() {
        log.info("Digest hebdomadaire: checking upcoming events");
        LocalDate today = LocalDate.now();
        LocalDate nextWeek = today.plusDays(7);
        List<Evenement> upcoming = evenementRepository.findByDateEvenementBetween(today, nextWeek);
        if (upcoming.isEmpty()) return;

        for (Evenement event : upcoming) {
            List<Reservation> reservations = reservationRepository.findByEvenementId(event.getIdEvenement());
            for (Reservation r : reservations) {
                try {
                    notificationService.create(
                        r.getClient().getCodeUtilisateur(),
                        "À venir cette semaine",
                        "Votre événement \"" + event.getTitre() + "\" a lieu le " + event.getDateEvenement(),
                        "EVENT_REMINDER",
                        String.valueOf(event.getIdEvenement())
                    );
                } catch (Exception e) {
                    log.warn("Failed to send digest to user {}: {}", r.getClient().getCodeUtilisateur(), e.getMessage());
                }
            }
        }
        log.info("Digest hebdomadaire envoyé pour {} événement(s)", upcoming.size());
    }
}
