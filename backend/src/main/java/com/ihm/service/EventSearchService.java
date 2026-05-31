package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.*;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import com.ihm.schemat.StatutPlace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import com.ihm.repository.*;

@Service
public class EventSearchService {

    private static final Logger log = LoggerFactory.getLogger(EventSearchService.class);
    private static final int POPULAR_LIMIT = 10;

    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;
    private final CorrespondARepository correspondARepository;
    private final SalleRepository salleRepository;

    public EventSearchService(EvenementRepository evenementRepository,
                              PlaceRepository placeRepository,
                              TicketRepository ticketRepository,
                              ConcernerRepository concernerRepository,
                              CorrespondARepository correspondARepository,
                              SalleRepository salleRepository) {
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
        this.correspondARepository = correspondARepository;
        this.salleRepository = salleRepository;
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> searchEvents(EventSearchRequest request) {
        log.debug("Searching events with query: {}, categorie: {}, ville: {}", request.getQ(), request.getCategorie(), request.getVille());

        String query = request.getQ() != null ? request.getQ() : "";
        LocalDate today = LocalDate.now();
        List<Evenement> events;

        boolean upcoming = request.getDateFrom() == null && request.getDateTo() == null;
        LocalDate dateFrom = request.getDateFrom() != null ? request.getDateFrom() : today;
        LocalDate dateTo = request.getDateTo() != null ? request.getDateTo() : today.plusYears(1);

        if (query.isEmpty() && request.getCategorie() == null && request.getVille() == null) {
            if (upcoming) {
                events = evenementRepository.findUpcomingEvents(today);
            } else {
                events = evenementRepository.findByDateRange(dateFrom, dateTo);
            }
        } else if (query.isEmpty()) {
            if (request.getCategorie() != null && request.getVille() != null) {
                events = evenementRepository.searchFullWithDates("", request.getCategorie(), request.getVille(), dateFrom, dateTo);
            } else if (request.getCategorie() != null) {
                events = evenementRepository.searchByTitleCategorieDateRange("", request.getCategorie(), dateFrom, dateTo);
            } else if (request.getVille() != null) {
                events = evenementRepository.searchByTitleVilleDateRange("", request.getVille(), dateFrom, dateTo);
            } else {
                events = Collections.emptyList();
            }
        } else if (request.getCategorie() == null && request.getVille() == null) {
            events = upcoming
                    ? evenementRepository.searchUpcoming(today, query)
                    : evenementRepository.searchByTitleAndDateRange(query, dateFrom, dateTo);
        } else if (request.getCategorie() != null && request.getVille() != null) {
            events = upcoming
                    ? evenementRepository.searchUpcomingFull(today, query, request.getCategorie(), request.getVille())
                    : evenementRepository.searchFullWithDates(query, request.getCategorie(), request.getVille(), dateFrom, dateTo);
        } else if (request.getCategorie() != null) {
            events = upcoming
                    ? evenementRepository.searchUpcomingByCategorie(today, query, request.getCategorie())
                    : evenementRepository.searchByTitleCategorieDateRange(query, request.getCategorie(), dateFrom, dateTo);
        } else {
            events = upcoming
                    ? evenementRepository.searchUpcomingByVille(today, query, request.getVille())
                    : evenementRepository.searchByTitleVilleDateRange(query, request.getVille(), dateFrom, dateTo);
        }

        if (request.getStatut() != null) {
            events = events.stream()
                    .filter(e -> request.getStatut().equals(e.getStatut()))
                    .collect(Collectors.toList());
        }

        if (request.getIdLieu() != null) {
            events = events.stream()
                    .filter(e -> e.getLieu() != null && request.getIdLieu().equals(e.getLieu().getIdLieu()))
                    .collect(Collectors.toList());
        }

        if (request.getPrixMin() != null || request.getPrixMax() != null) {
            Set<Integer> eventIds = events.stream().map(Evenement::getIdEvenement).collect(Collectors.toSet());
            if (!eventIds.isEmpty()) {
                Map<Integer, BigDecimal> minPrices = new HashMap<>();
                for (Integer eid : eventIds) {
                    BigDecimal minP = ticketRepository.findMinPriceByEvent(eid);
                    if (minP != null) minPrices.put(eid, minP);
                }
                events = events.stream()
                        .filter(e -> {
                            BigDecimal ep = minPrices.get(e.getIdEvenement());
                            if (ep == null) return false;
                            if (request.getPrixMin() != null && ep.compareTo(request.getPrixMin()) < 0) return false;
                            if (request.getPrixMax() != null && ep.compareTo(request.getPrixMax()) > 0) return false;
                            return true;
                        })
                        .collect(Collectors.toList());
            }
        }

        return events.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getUpcomingEvents() {
        log.debug("Fetching upcoming events");
        return evenementRepository.findUpcomingEvents(LocalDate.now())
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getPopularEvents() {
        log.debug("Fetching popular events");
        List<Evenement> upcoming = evenementRepository.findUpcomingEvents(LocalDate.now());
        return upcoming.stream()
                .sorted((a, b) -> {
                    long countA = concernerRepository.findByEvenement_IdEvenement(a.getIdEvenement()).size();
                    long countB = concernerRepository.findByEvenement_IdEvenement(b.getIdEvenement()).size();
                    return Long.compare(countB, countA);
                })
                .limit(POPULAR_LIMIT)
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public EventDetailDTO getEventDetail(Integer idEvent) {
        log.debug("Fetching event detail: {}", idEvent);
        Evenement event = evenementRepository.findByIdEvenement(idEvent)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvent));

        EventDetailDTO dto = new EventDetailDTO();
        dto.setIdEvenement(event.getIdEvenement());
        dto.setTitre(event.getTitre());
        dto.setDescription(event.getDescription());
        dto.setDateEvenement(event.getDateEvenement());
        dto.setHeureEvenement(event.getHeureEvenement());
        dto.setImage(event.getImage());
        dto.setStatut(event.getStatut());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setCategorieNom(event.getCategorie() != null ? event.getCategorie().getNomCategorie() : null);
        dto.setIdLieu(event.getLieu() != null ? event.getLieu().getIdLieu() : null);
        dto.setLieuNom(event.getLieu() != null ? event.getLieu().getNomLieu() : null);
        dto.setLieuAdresse(event.getLieu() != null ? event.getLieu().getAdresse() : null);
        dto.setLieuVille(event.getLieu() != null ? event.getLieu().getVille() : null);
        dto.setCodeOrganisateur(event.getOrganisateur().getCodeUtilisateur());
        dto.setOrganisateurNom(event.getOrganisateur().getNom() + " " + event.getOrganisateur().getPrenoms());

        List<Concerner> concerners = concernerRepository.findByEvenement_IdEvenement(idEvent);
        Set<String> reservedPlaces = new HashSet<>();
        for (Concerner c : concerners) {
            reservedPlaces.add(c.getPlace().getNumeroPlace());
        }

        long totalPlaces = placeRepository.countPlacesForEventLocation(idEvent);
        dto.setPlacesTotal(totalPlaces);
        dto.setPlacesDisponibles(totalPlaces - reservedPlaces.size());

        BigDecimal minPrice = ticketRepository.findMinPriceByEvent(idEvent);
        BigDecimal maxPrice = ticketRepository.findMaxPriceByEvent(idEvent);
        dto.setPrixMin(minPrice);
        dto.setPrixMax(maxPrice);

        return dto;
    }

    @Transactional(readOnly = true)
    public List<SeatingDTO> getAvailableSeats(Integer idEvent) {
        log.debug("Fetching available seats for event: {}", idEvent);
        Evenement event = evenementRepository.findByIdEvenement(idEvent)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvent));

        if (event.getLieu() == null) {
            return Collections.emptyList();
        }

        List<Concerner> concerners = concernerRepository.findByEvenement_IdEvenement(idEvent);
        Set<String> reservedPlaces = new HashSet<>();
        for (Concerner c : concerners) {
            reservedPlaces.add(c.getPlace().getNumeroPlace());
        }

        List<Salle> salles = salleRepository.findByLieu_IdLieu(event.getLieu().getIdLieu());
        List<Place> allPlaces = new ArrayList<>();
        for (Salle salle : salles) {
            allPlaces.addAll(placeRepository.findBySalle_NumeroSalle(salle.getNumeroSalle()));
        }

        List<Ticket> tickets = ticketRepository.findByConcerners_Evenement_IdEvenement(idEvent);
        Map<String, BigDecimal> placePrices = new HashMap<>();
        for (Ticket ticket : tickets) {
            for (Concerner c : concerners) {
                if (c.getTicket().getCodeTicket().equals(ticket.getCodeTicket())) {
                    placePrices.put(c.getPlace().getNumeroPlace(), ticket.getPrix());
                }
            }
        }

        List<SeatingDTO> seatingList = new ArrayList<>();
        for (Place place : allPlaces) {
            SeatingDTO seating = new SeatingDTO();
            seating.setNumeroPlace(place.getNumeroPlace());
            seating.setRang(place.getRange());
            seating.setTypePlace(place.getTypePlace());
            seating.setSalle(place.getSalle().getNumeroSalle());
            seating.setStatut(place.getStatut() != null ? place.getStatut().name() : "DISPONIBLE");
            boolean estReservee = reservedPlaces.contains(place.getNumeroPlace());
            if (StatutPlace.INDISPONIBLE.equals(place.getStatut())) {
                seating.setDisponible(false);
            } else {
                seating.setDisponible(!estReservee);
            }
            BigDecimal prixPlace = place.getPrix();
            if (prixPlace != null && prixPlace.compareTo(BigDecimal.ZERO) > 0) {
                seating.setPrix(prixPlace);
            } else {
                seating.setPrix(placePrices.getOrDefault(place.getNumeroPlace(), BigDecimal.ZERO));
            }
            seatingList.add(seating);
        }

        return seatingList;
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
