package com.ihm.service;

import com.ihm.repository.EvenementRepository;
import com.ihm.schemat.Evenement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class EventCleanupService {

    private static final Logger log = LoggerFactory.getLogger(EventCleanupService.class);

    private final EvenementRepository evenementRepository;

    public EventCleanupService(EvenementRepository evenementRepository) {
        this.evenementRepository = evenementRepository;
    }

    @Transactional
    @Scheduled(cron = "0 0 * * * *")
    public void autoExpirePastEvents() {
        LocalDate today = LocalDate.now();
        List<Evenement> pastEvents = evenementRepository
                .findByDateEvenementBeforeAndStatutNot(today, "termine");

        int expired = 0;
        for (Evenement event : pastEvents) {
            String oldStatut = event.getStatut();
            event.setStatut("termine");
            evenementRepository.save(event);
            log.info("Event '{}' (id={}) auto-expired: {} → termine", event.getTitre(), event.getIdEvenement(), oldStatut);
            expired++;
        }

        if (expired > 0) {
            log.info("Auto-expire: {} event(s) marqués termine", expired);
        }
    }

    @Transactional
    @Scheduled(cron = "0 0 6 * * *")
    public void autoStartTodayEvents() {
        LocalDate today = LocalDate.now();
        List<Evenement> todayEvents = evenementRepository
                .findByDateEvenementAndStatut(today, "planifie");

        int started = 0;
        for (Evenement event : todayEvents) {
            event.setStatut("en_cours");
            evenementRepository.save(event);
            log.info("Event '{}' (id={}) auto-started: planifie → en_cours", event.getTitre(), event.getIdEvenement());
            started++;
        }

        if (started > 0) {
            log.info("Auto-start: {} event(s) marqués en_cours", started);
        }
    }
}
