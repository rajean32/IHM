package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.DashboardDTO;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.DashboardDTO;
import com.ihm.repository.*;
import com.ihm.model.Concerner;
import com.ihm.model.CorrespondA;
import com.ihm.model.Evenement;
import com.ihm.model.EvenementPlaceConfiguration;
import com.ihm.model.Paiement;
import com.ihm.model.Reservation;
import com.ihm.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private static final Logger log = LoggerFactory.getLogger(DashboardService.class);

    private final EvenementRepository evenementRepository;
    private final ClientRepository clientRepository;
    private final OrganisateurRepository organisateurRepository;
    private final ReservationRepository reservationRepository;
    private final TicketRepository ticketRepository;
    private final PaiementRepository paiementRepository;
    private final LieuRepository lieuRepository;
    private final SalleRepository salleRepository;
    private final ConcernerRepository concernerRepository;
    private final CorrespondARepository correspondARepository;
    private final PlaceRepository placeRepository;
    private final EvenementPlaceConfigurationRepository configRepository;

    public DashboardService(EvenementRepository evenementRepository,
                            ClientRepository clientRepository,
                            OrganisateurRepository organisateurRepository,
                            ReservationRepository reservationRepository,
                            TicketRepository ticketRepository,
                            PaiementRepository paiementRepository,
                            LieuRepository lieuRepository,
                            SalleRepository salleRepository,
                            ConcernerRepository concernerRepository,
                            CorrespondARepository correspondARepository,
                            PlaceRepository placeRepository,
                            EvenementPlaceConfigurationRepository configRepository) {
        this.evenementRepository = evenementRepository;
        this.clientRepository = clientRepository;
        this.organisateurRepository = organisateurRepository;
        this.reservationRepository = reservationRepository;
        this.ticketRepository = ticketRepository;
        this.paiementRepository = paiementRepository;
        this.lieuRepository = lieuRepository;
        this.salleRepository = salleRepository;
        this.concernerRepository = concernerRepository;
        this.correspondARepository = correspondARepository;
        this.placeRepository = placeRepository;
        this.configRepository = configRepository;
    }

    // ventes journalieres d'un organisateur
    @Transactional(readOnly = true)
    public List<DashboardDTO.DailySales> getDailySales(String codeOrg) {
        List<Object[]> raw = paiementRepository.dailySalesByOrganizer(codeOrg);
        List<DashboardDTO.DailySales> result = new ArrayList<>();
        for (Object[] row : raw) {
            result.add(new DashboardDTO.DailySales(
                    ((java.sql.Date) row[0]).toLocalDate(),
                    row[1] != null ? (Long) row[1] : 0L,
                    row[2] != null ? ((BigDecimal) row[2]).doubleValue() : 0.0));
        }
        return result;
    }

    // statistiques administrateur
    @Transactional(readOnly = true)
    public DashboardDTO.AdminStats getAdminStats() {
        log.debug("Fetching admin dashboard stats");
        DashboardDTO.AdminStats stats = new DashboardDTO.AdminStats();

        stats.setTotalEvents(evenementRepository.count());
        stats.setTotalClients(clientRepository.countAllClients());
        stats.setTotalOrganisateurs(organisateurRepository.countAllOrganisateurs());
        stats.setTotalReservations(reservationRepository.count());
        stats.setTotalTicketsSold(ticketRepository.count());
        stats.setTotalRevenue(paiementRepository.sumTotal() != null ? paiementRepository.sumTotal() : BigDecimal.ZERO);
        stats.setTotalLieux(lieuRepository.countAllLieux());
        stats.setTotalSalles(salleRepository.count());

        List<Evenement> recent = evenementRepository.findRecentEvents(PageRequest.of(0, 5));
        stats.setRecentEvents(recent.stream().map(this::toDTO).collect(Collectors.toList()));

        List<Object[]> topReservations = paiementRepository.topReservationsByRevenue(PageRequest.of(0, 5));
        List<Map<String, Object>> topEvents = new ArrayList<>();
        for (Object[] row : topReservations) {
            Map<String, Object> map = new HashMap<>();
            map.put("reservationId", row[0]);
            map.put("revenue", row[1]);
            topEvents.add(map);
        }
        stats.setTopEvents(topEvents);

        Map<String, Long> eventsByStatus = new HashMap<>();
        for (Object[] row : evenementRepository.countByStatut()) {
            if (row[0] != null) {
                eventsByStatus.put((String) row[0], row[1] != null ? (Long) row[1] : 0L);
            }
        }
        stats.setEventsByStatus(eventsByStatus);

        Map<String, Long> eventsByCat = new HashMap<>();
        for (Object[] row : evenementRepository.countByCategorie()) {
            if (row[0] != null) {
                eventsByCat.put((String) row[0], row[1] != null ? (Long) row[1] : 0L);
            }
        }
        stats.setEventsByCategorie(eventsByCat);

        return stats;
    }

    // statistiques d'un organisateur
    @Transactional(readOnly = true)
    public DashboardDTO.OrganizerStats getOrganizerStats(String codeOrg) {
        log.debug("Fetching organizer stats for: {}", codeOrg);
        List<Evenement> myEvents = evenementRepository.findByOrganisateur_CodeUtilisateur(codeOrg);

        DashboardDTO.OrganizerStats stats = new DashboardDTO.OrganizerStats();
        stats.setCodeOrganisateur(codeOrg);
        stats.setTotalEvents(myEvents.size());
        stats.setMyEvents(myEvents.stream().map(this::toDTO).collect(Collectors.toList()));

        long totalTickets = 0;
        long totalReservations = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;
        for (Evenement event : myEvents) {
            totalTickets += concernerRepository.findByEvenement_IdEvenement(event.getIdEvenement()).size();
            totalRevenue = totalRevenue.add(paiementRepository.sumByReservation(event.getIdEvenement()) != null
                    ? paiementRepository.sumByReservation(event.getIdEvenement()) : BigDecimal.ZERO);
        }
        stats.setTotalTicketsSold(totalTickets);
        stats.setTotalReservations(totalReservations);
        stats.setTotalRevenue(totalRevenue);

        long totalPlaces = 0;
        for (Evenement event : myEvents) {
            totalPlaces += placeRepository.countPlacesForEventLocation(event.getIdEvenement());
        }
        stats.setTotalPlaces(totalPlaces);
        stats.setPlacesDisponibles(totalPlaces - totalTickets);
        stats.setFillRate(totalPlaces > 0 ? (double) totalTickets / totalPlaces * 100 : 0);

        stats.setDailySales(getDailySales(codeOrg));
        stats.setTopEvents(myEvents.stream()
                .sorted((a, b) -> Long.compare(
                        concernerRepository.findByEvenement_IdEvenement(b.getIdEvenement()).size(),
                        concernerRepository.findByEvenement_IdEvenement(a.getIdEvenement()).size()))
                .limit(5)
                .map(this::toDTO)
                .collect(Collectors.toList()));

        return stats;
    }

    // statistiques d'un evenement
    @Transactional(readOnly = true)
    public DashboardDTO.EventStats getEventStats(Integer idEvent) {
        log.debug("Fetching stats for event: {}", idEvent);
        Evenement event = evenementRepository.findByIdEvenement(idEvent)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvent));

        DashboardDTO.EventStats stats = new DashboardDTO.EventStats();
        stats.setIdEvenement(event.getIdEvenement());
        stats.setTitre(event.getTitre());
        stats.setStatut(event.getStatut());

        List<Concerner> concerners = concernerRepository.findByEvenement_IdEvenement(idEvent);
        long ticketsVendus = concerners.size();
        stats.setTotalTickets(ticketRepository.countByEvent(idEvent));
        stats.setTicketsVendus(ticketsVendus);
        stats.setTicketsDisponibles(stats.getTotalTickets() - ticketsVendus);

        BigDecimal revenue = BigDecimal.ZERO;
        for (Concerner c : concerners) {
            if (c.getTicket().getPrix() != null) {
                revenue = revenue.add(c.getTicket().getPrix());
            }
        }
        stats.setTotalRevenue(revenue);

        Set<Integer> reservationIds = new HashSet<>();
        for (Concerner c : concerners) {
            correspondARepository.findByTicket_CodeTicket(c.getTicket().getCodeTicket())
                    .forEach(ca -> reservationIds.add(ca.getReservation().getIdReservation()));
        }
        stats.setTotalReservations(reservationIds.size());

        Map<String, Long> ticketsByType = new HashMap<>();
        for (Concerner c : concerners) {
            EvenementPlaceConfiguration cfg = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(idEvent, c.getPlace().getNumeroPlace())
                    .orElse(null);
            String type = cfg != null && cfg.getTypePlace() != null ? cfg.getTypePlace() : "Standard";
            ticketsByType.merge(type, 1L, Long::sum);
        }
        stats.setTicketsByType(ticketsByType);

        return stats;
    }

    private EvenementDTO toDTO(Evenement event) {
        EvenementDTO dto = new EvenementDTO();
        dto.setIdEvenement(event.getIdEvenement());
        dto.setTitre(event.getTitre());
        dto.setDescription(event.getDescription());
        dto.setDateEvenement(event.getDateEvenement());
        dto.setHeureEvenement(event.getHeureEvenement());
        dto.setImage(ImageUtils.toDataUrl(event.getImage()));
        dto.setStatut(event.getStatut());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setCodeLieu(event.getLieu() != null ? event.getLieu().getCode() : null);
        dto.setCodeOrganisateur(event.getOrganisateur().getCodeUtilisateur());
        return dto;
    }
}
