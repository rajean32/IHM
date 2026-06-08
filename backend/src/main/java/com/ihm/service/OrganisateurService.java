package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.OrganisateurDTO;
import com.ihm.schema.PlaceDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.ConcernerRepository;
import com.ihm.repository.CorrespondARepository;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.repository.TicketRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Administrateur;
import com.ihm.model.Concerner;
import com.ihm.model.CorrespondA;
import com.ihm.model.Evenement;
import com.ihm.model.EvenementPlaceConfiguration;
import com.ihm.model.Organisateur;
import com.ihm.model.Place;
import com.ihm.model.Reservation;
import com.ihm.model.Salle;
import com.ihm.model.Ticket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrganisateurService {

    private static final Logger log = LoggerFactory.getLogger(OrganisateurService.class);

    private final OrganisateurRepository organisateurRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final PlaceRepository placeRepository;
    private final EvenementRepository evenementRepository;
    private final SalleRepository salleRepository;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final TicketRepository ticketRepository;
    private final ReservationRepository reservationRepository;
    private final CorrespondARepository correspondARepository;
    private final ConcernerRepository concernerRepository;

    public OrganisateurService(OrganisateurRepository organisateurRepository,
                                UtilisateurRepository utilisateurRepository,
                                AdministrateurRepository administrateurRepository,
                                PasswordEncoder passwordEncoder,
                                PlaceRepository placeRepository,
                                EvenementRepository evenementRepository,
                                SalleRepository salleRepository,
                                EvenementPlaceConfigurationRepository configRepository,
                                TicketRepository ticketRepository,
                                ReservationRepository reservationRepository,
                                CorrespondARepository correspondARepository,
                                ConcernerRepository concernerRepository) {
        this.organisateurRepository = organisateurRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.placeRepository = placeRepository;
        this.evenementRepository = evenementRepository;
        this.salleRepository = salleRepository;
        this.configRepository = configRepository;
        this.ticketRepository = ticketRepository;
        this.reservationRepository = reservationRepository;
        this.correspondARepository = correspondARepository;
        this.concernerRepository = concernerRepository;
    }

    // ========== Organisateur CRUD ==========

    public List<OrganisateurDTO> getAll() {
        log.debug("Fetching all organisateurs");
        return organisateurRepository.findAll()
                .stream()
                .map(this::toOrganisateurDTO)
                .collect(Collectors.toList());
    }

    public OrganisateurDTO getById(String code) {
        log.debug("Fetching organisateur by code: {}", code);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", code));
        return toOrganisateurDTO(org);
    }

    @Transactional
    public OrganisateurDTO create(OrganisateurDTO dto) {
        log.debug("Creating organisateur: {}", dto.getEmail());
        if (utilisateurRepository.existsByCodeUtilisateur(dto.getCodeOrganisateur())) {
            throw new DuplicateResourceException("Organisateur", "codeOrganisateur", dto.getCodeOrganisateur());
        }
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("Organisateur", "email", dto.getEmail());
        }
        Organisateur org = new Organisateur();
        org.setCodeUtilisateur(dto.getCodeOrganisateur());
        org.setNom(dto.getNom());
        org.setPrenoms(dto.getPrenoms());
        org.setSexe(dto.getSexe());
        org.setDateDeNaissance(dto.getDateDeNaissance());
        org.setEmail(dto.getEmail());
        org.setTel(dto.getTel());
        org.setMotDePasse(passwordEncoder.encode("default123"));
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            org.setAdministrateur(admin);
        }
        Organisateur saved = organisateurRepository.save(org);
        log.info("Organisateur created: {}", saved.getCodeUtilisateur());
        return toOrganisateurDTO(saved);
    }

    @Transactional
    public OrganisateurDTO update(String code, OrganisateurDTO dto) {
        log.debug("Updating organisateur: {}", code);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", code));
        if (dto.getNom() != null) org.setNom(dto.getNom());
        if (dto.getPrenoms() != null) org.setPrenoms(dto.getPrenoms());
        if (dto.getSexe() != null) org.setSexe(dto.getSexe());
        if (dto.getDateDeNaissance() != null) org.setDateDeNaissance(dto.getDateDeNaissance());
        if (dto.getEmail() != null) {
            if (!org.getEmail().equals(dto.getEmail()) && utilisateurRepository.existsByEmail(dto.getEmail())) {
                throw new DuplicateResourceException("Organisateur", "email", dto.getEmail());
            }
            org.setEmail(dto.getEmail());
        }
        if (dto.getTel() != null) org.setTel(dto.getTel());
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            org.setAdministrateur(admin);
        }
        Organisateur saved = organisateurRepository.save(org);
        log.info("Organisateur updated: {}", code);
        return toOrganisateurDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting organisateur: {}", code);
        if (!organisateurRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Organisateur", "codeOrganisateur", code);
        }
        organisateurRepository.deleteById(code);
        log.info("Organisateur deleted: {}", code);
    }

    // ========== Event-related venue and salle queries ==========

    @Transactional(readOnly = true)
    public List<Salle> getSallesForEvent(Integer eventId) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));
        if (event.getLieu() == null) {
            throw new BadRequestException("Event has no associated venue");
        }
        return salleRepository.findByLieu_Code(event.getLieu().getCode());
    }

    @Transactional(readOnly = true)
    public List<String> getDistinctRangsForEvent(Integer eventId, String numeroSalle) {
        return configRepository.findByEvenement_IdEvenement(eventId)
                .stream()
                .filter(c -> c.getPlace().getSalle().getNumeroSalle().equals(numeroSalle))
                .map(EvenementPlaceConfiguration::getRange)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO.EventPlaceConfig> getPlacesWithConfig(Integer eventId, String numeroSalle) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<EvenementPlaceConfiguration> configs = configRepository.findByEvenement_IdEvenement(eventId);

        if (numeroSalle != null && !numeroSalle.isBlank()) {
            configs = configs.stream()
                    .filter(c -> numeroSalle.equals(c.getPlace().getSalle().getNumeroSalle()))
                    .collect(Collectors.toList());
        }

        return configs.stream()
                .map(this::toEventPlaceConfigDTO)
                .collect(Collectors.toList());
    }

    // ========== Event-specific pricing (via EvenementPlaceConfiguration) ==========

    @Transactional
    public int applyRowPricingWithConfig(Integer eventId, String rang, String typePlace, BigDecimal prix) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<EvenementPlaceConfiguration> configs = configRepository.findByEvenement_IdEvenement(eventId)
                .stream()
                .filter(c -> rang.equals(c.getRange()))
                .collect(Collectors.toList());

        int updated = 0;
        for (EvenementPlaceConfiguration config : configs) {
            config.setTypePlace(typePlace);
            if (prix != null) {
                config.setPrix(prix);
            }
            configRepository.save(config);
            updated++;
        }
        log.info("Row pricing applied for event {} rang '{}': {} places updated", eventId, rang, updated);
        return updated;
    }

    @Transactional
    public EvenementDTO.EventPlaceConfig updatePlacePricingWithConfig(Integer eventId, String numeroPlace,
                                                   String typePlace, BigDecimal prix) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        EvenementPlaceConfiguration config = configRepository
                .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, numeroPlace)
                .orElseThrow(() -> new ResourceNotFoundException("EvenementPlaceConfiguration", "place", numeroPlace));

        if (typePlace != null) config.setTypePlace(typePlace);
        if (prix != null) config.setPrix(prix);
        configRepository.save(config);

        log.info("Place pricing updated for event {} place {}", eventId, numeroPlace);
        return toEventPlaceConfigDTO(config);
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO.EventPlaceConfig> searchPlaces(Integer eventId, String query, String typeFilter) {
        if (typeFilter != null && !typeFilter.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .findByEventAndTypePlace(eventId, typeFilter);
            return configs.stream()
                    .map(this::toEventPlaceConfigDTO)
                    .collect(Collectors.toList());
        }
        if (query != null && !query.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .searchByEventAndQuery(eventId, query);
            return configs.stream()
                    .map(this::toEventPlaceConfigDTO)
                    .collect(Collectors.toList());
        }
        return getPlacesWithConfig(eventId, null);
    }

    @Transactional
    public int applyTypePricing(Integer eventId, String typePlace, BigDecimal prix) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<EvenementPlaceConfiguration> configs = configRepository
                .findByEventAndTypePlace(eventId, typePlace);

        if (configs.isEmpty()) {
            log.warn("No places with type '{}' found for event {}", typePlace, eventId);
            return 0;
        }

        int updated = 0;
        for (EvenementPlaceConfiguration config : configs) {
            config.setPrix(prix);
            configRepository.save(config);
            updated++;
        }
        log.info("Type pricing applied for event {} type '{}': {} places updated", eventId, typePlace, updated);
        return updated;
    }

    @Transactional
    public int assignTypeToPlaces(Integer eventId, String typePlace,
                                   List<String> placeIds, List<String> rows) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<EvenementPlaceConfiguration> configs = configRepository.findByEvenement_IdEvenement(eventId);

        List<EvenementPlaceConfiguration> targetConfigs = configs.stream()
                .filter(c -> {
                    boolean matchPlace = placeIds != null && placeIds.contains(c.getPlace().getNumeroPlace());
                    boolean matchRow = rows != null && rows.contains(c.getRange());
                    return matchPlace || matchRow;
                })
                .collect(Collectors.toList());

        if (targetConfigs.isEmpty()) {
            log.warn("No places match the selection for event {}", eventId);
            return 0;
        }

        int updated = 0;
        for (EvenementPlaceConfiguration config : targetConfigs) {
            config.setTypePlace(typePlace);
            configRepository.save(config);
            updated++;
        }
        log.info("Type assigned for event {}: {} places -> '{}'", eventId, updated, typePlace);
        return updated;
    }

    @Transactional(readOnly = true)
    public List<String> getDistinctTypesForEvent(Integer eventId) {
        return configRepository.findByEvenement_IdEvenement(eventId)
                .stream()
                .map(EvenementPlaceConfiguration::getTypePlace)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    // ========== Ticket & Reservation queries ==========

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTicketsForEvent(Integer eventId) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Ticket> tickets = ticketRepository.findByConcerners_Evenement_IdEvenement(eventId);
        return tickets.stream().map(t -> {
            Map<String, Object> m = new java.util.HashMap<>();
            m.put("codeTicket", t.getCodeTicket());
            m.put("prix", t.getPrix());
            List<Concerner> cs = concernerRepository.findByTicket_CodeTicket(t.getCodeTicket());
            if (!cs.isEmpty()) {
                Concerner c = cs.get(0);
                m.put("numeroPlace", c.getPlace().getNumeroPlace());
                m.put("rang", c.getPlace().getRangePlace());
                EvenementPlaceConfiguration cfg = configRepository
                        .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, c.getPlace().getNumeroPlace())
                        .orElse(null);
                m.put("typePlace", cfg != null ? cfg.getTypePlace() : null);
            }
            List<CorrespondA> corrs = correspondARepository.findByTicket_CodeTicket(t.getCodeTicket());
            if (!corrs.isEmpty()) {
                m.put("idReservation", corrs.get(0).getReservation().getIdReservation());
                m.put("clientNom", corrs.get(0).getReservation().getClient().getNom() + " "
                        + corrs.get(0).getReservation().getClient().getPrenoms());
                m.put("statut", corrs.get(0).getReservation().getPaiement() != null ? "PAYE" : "EN_ATTENTE");
            } else {
                m.put("statut", "DISPONIBLE");
            }
            return m;
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getReservationsForEvent(Integer eventId) {
        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Reservation> reservations = reservationRepository.findByEvenementId(eventId);
        return reservations.stream().map(r -> {
            Map<String, Object> m = new java.util.HashMap<>();
            m.put("idReservation", r.getIdReservation());
            m.put("dateReservation", r.getDateReservation().toString());
            m.put("codeClient", r.getClient().getCodeUtilisateur());
            m.put("clientNom", r.getClient().getNom() + " " + r.getClient().getPrenoms());
            m.put("clientTel", r.getClient().getTel());
            m.put("clientEmail", r.getClient().getEmail());
            m.put("paiement", r.getPaiement() != null ? Map.of(
                    "montant", r.getPaiement().getMontant(),
                    "modePaiement", r.getPaiement().getModePaiement(),
                    "datePaiement", r.getPaiement().getDatePaiement().toString()
            ) : null);
            List<Map<String, Object>> tickets = r.getCorrespondances().stream().map(ca -> {
                Map<String, Object> t = new java.util.HashMap<>();
                t.put("codeTicket", ca.getTicket().getCodeTicket());
                t.put("prix", ca.getTicket().getPrix());
                List<Concerner> cs = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
                if (!cs.isEmpty()) {
                    Concerner c = cs.get(0);
                    t.put("numeroPlace", c.getPlace().getNumeroPlace());
                    t.put("rang", c.getPlace().getRangePlace());
                    EvenementPlaceConfiguration cfg = configRepository
                            .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, c.getPlace().getNumeroPlace())
                            .orElse(null);
                    t.put("typePlace", cfg != null ? cfg.getTypePlace() : null);
                }
                return t;
            }).collect(Collectors.toList());
            m.put("tickets", tickets);
            m.put("nombreTickets", tickets.size());
            return m;
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getReservationDetail(Integer reservationId) {
        Reservation r = reservationRepository.findByIdWithCorrespondances(reservationId)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", reservationId));

        Map<String, Object> m = new java.util.HashMap<>();
        m.put("idReservation", r.getIdReservation());
        m.put("dateReservation", r.getDateReservation().toString());
        m.put("codeClient", r.getClient().getCodeUtilisateur());
        m.put("clientNom", r.getClient().getNom() + " " + r.getClient().getPrenoms());
        m.put("clientTel", r.getClient().getTel());
        m.put("clientEmail", r.getClient().getEmail());
        m.put("paiement", r.getPaiement() != null ? Map.of(
                "montant", r.getPaiement().getMontant(),
                "modePaiement", r.getPaiement().getModePaiement(),
                "datePaiement", r.getPaiement().getDatePaiement().toString()
        ) : null);
        List<Map<String, Object>> tickets = r.getCorrespondances().stream().map(ca -> {
            Map<String, Object> t = new java.util.HashMap<>();
            t.put("codeTicket", ca.getTicket().getCodeTicket());
            t.put("prix", ca.getTicket().getPrix());
            List<Concerner> cs = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
            if (!cs.isEmpty()) {
                Concerner c = cs.get(0);
                t.put("numeroPlace", c.getPlace().getNumeroPlace());
                t.put("rang", c.getPlace().getRangePlace());
                EvenementPlaceConfiguration cfg = configRepository
                        .findByEvenement_IdEvenementAndPlace_NumeroPlace(c.getEvenement().getIdEvenement(), c.getPlace().getNumeroPlace())
                        .orElse(null);
                t.put("typePlace", cfg != null ? cfg.getTypePlace() : null);
                t.put("evenementTitre", c.getEvenement().getTitre());
                t.put("evenementDate", c.getEvenement().getDateEvenement().toString());
            }
            return t;
        }).collect(Collectors.toList());
        m.put("tickets", tickets);
        m.put("nombreTickets", tickets.size());
        return m;
    }

    // ========== Basic place queries ==========

    @Transactional(readOnly = true)
    public List<PlaceDTO> getPlacesForEvent(Integer eventId) {
        return placeRepository.findPlacesForEventLocation(eventId)
                .stream()
                .map(this::toPlaceDTO)
                .collect(Collectors.toList());
    }

    // ========== Private DTO converters ==========

    private OrganisateurDTO toOrganisateurDTO(Organisateur org) {
        OrganisateurDTO dto = new OrganisateurDTO();
        dto.setCodeOrganisateur(org.getCodeUtilisateur());
        dto.setNom(org.getNom());
        dto.setPrenoms(org.getPrenoms());
        dto.setSexe(org.getSexe());
        dto.setDateDeNaissance(org.getDateDeNaissance());
        dto.setEmail(org.getEmail());
        dto.setTel(org.getTel());
        if (org.getAdministrateur() != null) {
            dto.setCodeAdministrateur(org.getAdministrateur().getCodeAdministrateur());
        }
        return dto;
    }

    private PlaceDTO toPlaceDTO(Place place) {
        PlaceDTO dto = new PlaceDTO();
        dto.setNumeroPlace(place.getNumeroPlace());
        dto.setNumeroSalle(place.getSalle().getNumeroSalle());
        return dto;
    }

    private EvenementDTO.EventPlaceConfig toEventPlaceConfigDTO(EvenementPlaceConfiguration config) {
        EvenementDTO.EventPlaceConfig dto = new EvenementDTO.EventPlaceConfig();
        dto.setNumeroPlace(config.getPlace().getNumeroPlace());
        dto.setRange(config.getRange());
        dto.setTypePlace(config.getTypePlace());
        dto.setPrix(config.getPrix());
        dto.setStatut(config.getStatut());
        dto.setNumeroSalle(config.getPlace().getSalle().getNumeroSalle());
        dto.setNomSalle(config.getPlace().getSalle().getNomSalle());
        return dto;
    }
}
