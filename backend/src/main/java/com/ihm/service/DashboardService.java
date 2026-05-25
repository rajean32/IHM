package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.DashboardStatsDTO;
import com.ihm.model.dto.EvenementDTO;
import com.ihm.model.dto.EventStatsDTO;
import com.ihm.model.dto.OrganizerDashboardDTO;
import com.ihm.repository.*;
import com.ihm.schemat.Concerner;
import com.ihm.schemat.Evenement;
import com.ihm.schemat.Paiement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

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
                            PlaceRepository placeRepository) {
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
    }

    public DashboardStatsDTO getAdminStats() {
        log.debug("Fetching admin dashboard stats");
        DashboardStatsDTO stats = new DashboardStatsDTO();

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
            eventsByStatus.put((String) row[0], (Long) row[1]);
        }
        stats.setEventsByStatus(eventsByStatus);

        Map<String, Long> eventsByCat = new HashMap<>();
        for (Object[] row : evenementRepository.countByCategorie()) {
            eventsByCat.put((String) row[0], (Long) row[1]);
        }
        stats.setEventsByCategorie(eventsByCat);

        return stats;
    }

    public OrganizerDashboardDTO getOrganizerStats(String codeOrg) {
        log.debug("Fetching organizer stats for: {}", codeOrg);
        List<Evenement> myEvents = evenementRepository.findByOrganisateur_CodeUtilisateur(codeOrg);

        OrganizerDashboardDTO stats = new OrganizerDashboardDTO();
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

        return stats;
    }

    public EventStatsDTO getEventStats(Integer idEvent) {
        log.debug("Fetching stats for event: {}", idEvent);
        Evenement event = evenementRepository.findByIdEvenement(idEvent)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvent));

        EventStatsDTO stats = new EventStatsDTO();
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
            String type = c.getPlace().getTypePlace() != null ? c.getPlace().getTypePlace() : "Standard";
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
        dto.setImage(event.getImage());
        dto.setStatut(event.getStatut());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setIdLieu(event.getLieu() != null ? event.getLieu().getIdLieu() : null);
        dto.setCodeOrganisateur(event.getOrganisateur().getCodeUtilisateur());
        return dto;
    }
}
