package com.ihm.service;

import com.ihm.model.dto.ConsistencyReportDTO;
import com.ihm.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class DataConsistencyService {

    private static final Logger log = LoggerFactory.getLogger(DataConsistencyService.class);

    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final ConcernerRepository concernerRepository;
    private final CorrespondARepository correspondARepository;
    private final TicketRepository ticketRepository;
    private final ReservationRepository reservationRepository;
    private final PaiementRepository paiementRepository;
    private final EvenementPlaceConfigurationRepository configRepository;

    public DataConsistencyService(EvenementRepository evenementRepository,
                                  PlaceRepository placeRepository,
                                  ConcernerRepository concernerRepository,
                                  CorrespondARepository correspondARepository,
                                  TicketRepository ticketRepository,
                                  ReservationRepository reservationRepository,
                                  PaiementRepository paiementRepository,
                                  EvenementPlaceConfigurationRepository configRepository) {
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.concernerRepository = concernerRepository;
        this.correspondARepository = correspondARepository;
        this.ticketRepository = ticketRepository;
        this.reservationRepository = reservationRepository;
        this.paiementRepository = paiementRepository;
        this.configRepository = configRepository;
    }

    public ConsistencyReportDTO generateReport() {
        List<String> issues = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        long pastActiveEvents = evenementRepository.countByDateEvenementBeforeAndStatutNot(
                java.time.LocalDate.now(), "termine");
        if (pastActiveEvents > 0) {
            issues.add(pastActiveEvents + " événement(s) passé(s) encore actif (non terminés)");
        }

        long orphanTickets = ticketRepository.countOrphanTickets();
        if (orphanTickets > 0) {
            issues.add(orphanTickets + " ticket(s) sans réservation associée (orphelins)");
        }

        long reservedPlacesWithoutConcerner = placeRepository.countReservedWithoutConcerner();
        if (reservedPlacesWithoutConcerner > 0) {
            warnings.add(reservedPlacesWithoutConcerner + " place(s) marquées RESERVEE sans lien Concerner");
        }

        long reservationsWithoutPayment = reservationRepository.countWithoutPayment();
        if (reservationsWithoutPayment > 0) {
            warnings.add(reservationsWithoutPayment + " réservation(s) sans paiement associé");
        }

        long eventsWithoutSalles = evenementRepository.countEventsWithoutSallePlaces();
        if (eventsWithoutSalles > 0) {
            issues.add(eventsWithoutSalles + " événement(s) sans aucune place configurée dans leur salle");
        }

        return new ConsistencyReportDTO(issues, warnings);
    }

    public void logReport() {
        ConsistencyReportDTO report = generateReport();
        if (!report.getIssues().isEmpty()) {
            log.warn("=== INCONSISTANCES DÉTECTÉES ===");
            report.getIssues().forEach(i -> log.warn("  ISSUE: {}", i));
        }
        if (!report.getWarnings().isEmpty()) {
            log.warn("=== AVERTISSEMENTS ===");
            report.getWarnings().forEach(w -> log.warn("  WARN: {}", w));
        }
        if (report.getIssues().isEmpty() && report.getWarnings().isEmpty()) {
            log.info("Data consistency check passed — no issues found.");
        }
    }
}
