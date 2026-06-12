package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.SalleDTO;
import com.ihm.repository.*;
import com.ihm.model.*;
import com.ihm.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class EvenementService {

    private static final Logger log = LoggerFactory.getLogger(EvenementService.class);

    private static final List<String> VALID_STATUSES = List.of("planifie", "en_cours", "termine", "annule", "suspendu", "valide");

    private static final Map<String, List<String>> ALLOWED_TRANSITIONS = Map.of(
        "planifie", List.of("en_cours", "termine", "annule", "suspendu", "valide"),
        "en_cours", List.of("termine", "annule", "suspendu"),
        "termine",   List.of(),
        "annule",    List.of(),
        "suspendu",  List.of("valide", "annule"),
        "valide",    List.of("suspendu", "annule")
    );

    private static final int POPULAR_LIMIT = 10;

    private final EvenementRepository evenementRepository;
    private final CategorieRepository categorieRepository;
    private final LieuRepository lieuRepository;
    private final OrganisateurRepository organisateurRepository;
    private final ConcernerRepository concernerRepository;
    private final PlaceRepository placeRepository;
    private final TicketRepository ticketRepository;
    private final CorrespondARepository correspondARepository;
    private final SalleRepository salleRepository;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final ReservationRepository reservationRepository;
    private final PaiementService paiementService;

    @PersistenceContext
    private EntityManager entityManager;

    public EvenementService(EvenementRepository evenementRepository,
                            CategorieRepository categorieRepository,
                            LieuRepository lieuRepository,
                            OrganisateurRepository organisateurRepository,
                            ConcernerRepository concernerRepository,
                            PlaceRepository placeRepository,
                            TicketRepository ticketRepository,
                            CorrespondARepository correspondARepository,
                            SalleRepository salleRepository,
                            EvenementPlaceConfigurationRepository configRepository,
                            ReservationRepository reservationRepository,
                            PaiementService paiementService) {
        this.evenementRepository = evenementRepository;
        this.categorieRepository = categorieRepository;
        this.lieuRepository = lieuRepository;
        this.organisateurRepository = organisateurRepository;
        this.concernerRepository = concernerRepository;
        this.placeRepository = placeRepository;
        this.ticketRepository = ticketRepository;
        this.correspondARepository = correspondARepository;
        this.salleRepository = salleRepository;
        this.configRepository = configRepository;
        this.reservationRepository = reservationRepository;
        this.paiementService = paiementService;
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getAll() {
        log.debug("Fetching all events");
        return evenementRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public EvenementDTO getById(Integer id) {
        log.debug("Fetching event by id: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        return toDTO(event);
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByOrganisateur(String codeOrg) {
        log.debug("Fetching events by organizer: {}", codeOrg);
        return evenementRepository.findByOrganisateur_CodeUtilisateur(codeOrg)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByCategorie(String codeCat) {
        log.debug("Fetching events by category: {}", codeCat);
        return evenementRepository.findByCategorie_CodeCategorie(codeCat)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByStatut(String statut) {
        log.debug("Fetching events by status: {}", statut);
        return evenementRepository.findByStatut(statut)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public EvenementDTO create(EvenementDTO dto) {
        log.debug("Creating event: {}", dto.getTitre());

        if (dto.getStatut() != null && !VALID_STATUSES.contains(dto.getStatut())) {
            throw new BadRequestException("Invalid status. Valid values: " + VALID_STATUSES);
        }

        Evenement event = new Evenement();
        event.setTitre(dto.getTitre());
        event.setDescription(dto.getDescription());
        event.setDateEvenement(dto.getDateEvenement());
        event.setHeureEvenement(dto.getHeureEvenement());
        event.setStatut(dto.getStatut() != null ? dto.getStatut() : "planifie");

        if (dto.getCodeCategorie() != null) {
            Categorie cat = categorieRepository.findByCodeCategorie(dto.getCodeCategorie())
                    .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", dto.getCodeCategorie()));
            event.setCategorie(cat);
        }
        if (dto.getCodeLieu() == null) {
            throw new BadRequestException("Lieu (codeLieu) is required to create an event");
        }
        Lieu lieu = lieuRepository.findById(dto.getCodeLieu())
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "codeLieu", dto.getCodeLieu()));
        event.setLieu(lieu);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(dto.getCodeOrganisateur())
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", dto.getCodeOrganisateur()));
        event.setOrganisateur(org);

        Evenement saved = evenementRepository.save(event);

        List<Salle> salles = salleRepository.findByLieu_Code(lieu.getCode());
        for (Salle salle : salles) {
            List<Place> places = placeRepository.findBySalle_NumeroSalle(salle.getNumeroSalle());
            for (Place place : places) {
                if (!configRepository.existsByEvenement_IdEvenementAndPlace_NumeroPlace(saved.getIdEvenement(), place.getNumeroPlace())) {
                    String rang = "?";
                    EvenementPlaceConfiguration config = new EvenementPlaceConfiguration();
                    config.setEvenement(saved);
                    config.setPlace(place);
                    config.setRange(rang);
                    config.setTypePlace("Standard");
                    config.setPrix(BigDecimal.ZERO);
                    config.setStatut("DISPONIBLE");
                    configRepository.save(config);
                }
            }
        }

        log.info("Event created: id={}", saved.getIdEvenement());
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO update(Integer id, EvenementDTO dto) {
        log.debug("Updating event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (dto.getTitre() != null) event.setTitre(dto.getTitre());
        if (dto.getDescription() != null) event.setDescription(dto.getDescription());
        if (dto.getDateEvenement() != null) event.setDateEvenement(dto.getDateEvenement());
        if (dto.getHeureEvenement() != null) event.setHeureEvenement(dto.getHeureEvenement());
        if (dto.getStatut() != null) {
            if (!VALID_STATUSES.contains(dto.getStatut())) {
                throw new BadRequestException("Invalid status. Valid values: " + VALID_STATUSES);
            }
            String current = event.getStatut();
            List<String> allowed = ALLOWED_TRANSITIONS.getOrDefault(current, List.of());
            if (!allowed.contains(dto.getStatut()) && !dto.getStatut().equals(current)) {
                throw new BadRequestException("Status transition not allowed: " + current + " → " + dto.getStatut());
            }
            event.setStatut(dto.getStatut());
        }
        if (dto.getCodeCategorie() != null) {
            Categorie cat = categorieRepository.findByCodeCategorie(dto.getCodeCategorie())
                    .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", dto.getCodeCategorie()));
            event.setCategorie(cat);
        }
        if (dto.getCodeLieu() != null) {
            Lieu lieu = lieuRepository.findById(dto.getCodeLieu())
                    .orElseThrow(() -> new ResourceNotFoundException("Lieu", "codeLieu", dto.getCodeLieu()));
            event.setLieu(lieu);
        }
        Evenement saved = evenementRepository.save(event);
        log.info("Event updated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting event: {}", id);
        if (!evenementRepository.existsByIdEvenement(id)) {
            throw new ResourceNotFoundException("Evenement", "idEvenement", id);
        }
        entityManager.createQuery("DELETE FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :id")
            .setParameter("id", id)
            .executeUpdate();
        evenementRepository.deleteById(id);
        log.info("Event deleted: id={}", id);
    }

    @Transactional
    public EvenementDTO validate(Integer id) {
        log.debug("Validating event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"planifie".equals(event.getStatut())) {
            throw new BadRequestException("Only planned events can be validated. Current status: " + event.getStatut());
        }
        event.setStatut("valide");
        Evenement saved = evenementRepository.save(event);
        log.info("Event validated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO suspend(Integer id) {
        log.debug("Suspending event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"valide".equals(event.getStatut()) && !"planifie".equals(event.getStatut()) && !"en_cours".equals(event.getStatut())) {
            throw new BadRequestException("Event cannot be suspended. Current status: " + event.getStatut());
        }
        event.setStatut("suspendu");
        Evenement saved = evenementRepository.save(event);
        log.info("Event suspended: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO resume(Integer id) {
        log.debug("Resuming event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"suspendu".equals(event.getStatut())) {
            throw new BadRequestException("Only suspended events can be resumed. Current status: " + event.getStatut());
        }
        event.setStatut("valide");
        Evenement saved = evenementRepository.save(event);
        log.info("Event resumed: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO cancel(Integer id, String motif) {
        log.debug("Cancelling event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if ("annule".equals(event.getStatut()) || "termine".equals(event.getStatut())) {
            throw new BadRequestException("Event cannot be cancelled. Current status: " + event.getStatut());
        }
        
        // Get all reservations for this event
        List<Reservation> reservations = reservationRepository.findByEvenementId(id);
        
        // Process automatic refunds
        for (Reservation reservation : reservations) {
            try {
                paiementService.rembourserReservation(reservation.getIdReservation(), 
                        reservation.getClient().getCodeUtilisateur(), true);
                log.info("Auto-refund processed for reservation {} after event cancellation", 
                        reservation.getIdReservation());
            } catch (Exception e) {
                log.error("Error processing refund for reservation {}: {}", 
                        reservation.getIdReservation(), e.getMessage());
            }
        }
        
        event.setStatut("annule");
        event.setMotifAnnulation(motif);
        Evenement saved = evenementRepository.save(event);
        log.info("Event cancelled: id={}, {} reservation(s) refunded", id, reservations.size());
        return toDTO(saved);
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> searchEvents(EvenementDTO.EventSearchRequest request) {
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

        if (request.getCodeLieu() != null) {
            events = events.stream()
                    .filter(e -> e.getLieu() != null && request.getCodeLieu().equals(e.getLieu().getCode()))
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
    public EvenementDTO.EventDetail getEventDetail(Integer idEvent) {
        log.debug("Fetching event detail: {}", idEvent);
        Evenement event = evenementRepository.findByIdEvenement(idEvent)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvent));

        EvenementDTO.EventDetail dto = new EvenementDTO.EventDetail();
        dto.setIdEvenement(event.getIdEvenement());
        dto.setTitre(event.getTitre());
        dto.setDescription(event.getDescription());
        dto.setDateEvenement(event.getDateEvenement());
        dto.setHeureEvenement(event.getHeureEvenement());
        dto.setImage(ImageUtils.toDataUrl(event.getImage()));
        dto.setStatut(event.getStatut());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setCategorieNom(event.getCategorie() != null ? event.getCategorie().getNomCategorie() : null);
        dto.setCodeLieu(event.getLieu() != null ? event.getLieu().getCode() : null);
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

        List<EvenementPlaceConfiguration> configs = configRepository.findByEvenement_IdEvenement(idEvent);
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        for (EvenementPlaceConfiguration cfg : configs) {
            BigDecimal p = cfg.getPrix();
            if (p != null && p.compareTo(BigDecimal.ZERO) > 0) {
                if (minPrice == null || p.compareTo(minPrice) < 0) minPrice = p;
                if (maxPrice == null || p.compareTo(maxPrice) > 0) maxPrice = p;
            }
        }
        dto.setPrixMin(minPrice);
        dto.setPrixMax(maxPrice);

        return dto;
    }

    @Transactional(readOnly = true)
    public List<SalleDTO.SeatingDTO> getAvailableSeats(Integer idEvent) {
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

        List<EvenementPlaceConfiguration> configs = configRepository.findByEvenement_IdEvenement(idEvent);
        Map<String, EvenementPlaceConfiguration> configMap = new HashMap<>();
        for (EvenementPlaceConfiguration cfg : configs) {
            configMap.put(cfg.getPlace().getNumeroPlace(), cfg);
        }

        List<Salle> salles = salleRepository.findByLieu_Code(event.getLieu().getCode());
        List<SalleDTO.SeatingDTO> seatingList = new ArrayList<>();
        for (Salle salle : salles) {
            List<Place> places = placeRepository.findBySalle_NumeroSalle(salle.getNumeroSalle());
            for (Place place : places) {
                SalleDTO.SeatingDTO seating = new SalleDTO.SeatingDTO();
                seating.setNumeroPlace(place.getNumeroPlace());
                seating.setSalle(place.getSalle().getNumeroSalle());

                EvenementPlaceConfiguration cfg = configMap.get(place.getNumeroPlace());
                if (cfg != null) {
                    seating.setRang(cfg.getRange());
                    seating.setTypePlace(cfg.getTypePlace());
                    seating.setPrix(cfg.getPrix());
                    seating.setStatut(cfg.getStatut());
                    boolean estReservee = reservedPlaces.contains(place.getNumeroPlace());
                    seating.setDisponible("DISPONIBLE".equals(cfg.getStatut()) && !estReservee);
                } else {
                    seating.setRang("?");
                    seating.setTypePlace("Standard");
                    seating.setPrix(null);
                    seating.setStatut("DISPONIBLE");
                    seating.setDisponible(false);
                }
                seatingList.add(seating);
            }
        }

        return seatingList;
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

    @Transactional
    public void uploadImage(Integer id, MultipartFile file) {
        log.debug("Uploading image for event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        try {
            event.setImage(file.getBytes());
            evenementRepository.save(event);
            log.info("Image uploaded for event: {}", id);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read uploaded image file", e);
        }
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
        dto.setMotifAnnulation(event.getMotifAnnulation());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setCategorieNom(event.getCategorie() != null ? event.getCategorie().getNomCategorie() : null);
        dto.setCodeLieu(event.getLieu() != null ? event.getLieu().getCode() : null);
        dto.setLieuNom(event.getLieu() != null ? event.getLieu().getNomLieu() : null);
        dto.setCodeOrganisateur(event.getOrganisateur().getCodeUtilisateur());
        dto.setOrganisateurNom(event.getOrganisateur().getPrenoms() + " " + event.getOrganisateur().getNom());
        if (event.getIdEvenement() != null && event.getLieu() != null) {
            long total = placeRepository.countPlacesForEventLocation(event.getIdEvenement());
            long reserved = concernerRepository.findByEvenement_IdEvenement(event.getIdEvenement()).size();
            dto.setPlacesTotal(total);
            dto.setPlacesDisponibles(total - reserved);
        }
        return dto;
    }
}