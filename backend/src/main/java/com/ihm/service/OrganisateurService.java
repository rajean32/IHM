package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.OrganisateurDTO;
import com.ihm.schema.PlaceDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Administrateur;
import com.ihm.model.Evenement;
import com.ihm.model.EvenementPlaceConfiguration;
import com.ihm.model.Organisateur;
import com.ihm.model.Place;
import com.ihm.model.Salle;
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

    public OrganisateurService(OrganisateurRepository organisateurRepository,
                                UtilisateurRepository utilisateurRepository,
                                AdministrateurRepository administrateurRepository,
                                PasswordEncoder passwordEncoder,
                                PlaceRepository placeRepository,
                                EvenementRepository evenementRepository,
                                SalleRepository salleRepository,
                                EvenementPlaceConfigurationRepository configRepository) {
        this.organisateurRepository = organisateurRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.placeRepository = placeRepository;
        this.evenementRepository = evenementRepository;
        this.salleRepository = salleRepository;
        this.configRepository = configRepository;
    }

    // ========== Organisateur CRUD ==========

    // recuperation de tous les organisateurs
    public List<OrganisateurDTO> getAll() {
        log.debug("Fetching all organisateurs");
        return organisateurRepository.findAll()
                .stream()
                .map(this::toOrganisateurDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un organisateur
    public OrganisateurDTO getById(String code) {
        log.debug("Fetching organisateur by code: {}", code);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", code));
        return toOrganisateurDTO(org);
    }

    // creation d'un organisateur
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

    // mise a jour d'un organisateur
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

    // suppression d'un organisateur
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

    // salles d'un evenement
    @Transactional(readOnly = true)
    public List<Salle> getSallesForEvent(Integer eventId) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));
        if (event.getLieu() == null) {
            throw new BadRequestException("Event has no associated venue");
        }
        return salleRepository.findByLieu_Code(event.getLieu().getCode());
    }

    // rangs distincts d'une salle
    @Transactional(readOnly = true)
    public List<String> getDistinctRangsForSalle(String numeroSalle) {
        return placeRepository.findBySalle_NumeroSalle(numeroSalle)
                .stream()
                .map(Place::getRange)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    // places avec configuration
    @Transactional(readOnly = true)
    public List<EvenementDTO.EventPlaceConfig> getPlacesWithConfig(Integer eventId, String numeroSalle) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Place> places;
        if (numeroSalle != null && !numeroSalle.isBlank()) {
            places = placeRepository.findBySalle_NumeroSalle(numeroSalle);
        } else {
            places = placeRepository.findPlacesForEventLocation(eventId);
        }

        Map<String, EvenementPlaceConfiguration> configMap = configRepository
                .findByEvenement_IdEvenement(eventId)
                .stream()
                .collect(Collectors.toMap(c -> c.getPlace().getNumeroPlace(), c -> c));

        List<EvenementDTO.EventPlaceConfig> result = new ArrayList<>();
        for (Place place : places) {
            EvenementPlaceConfiguration config = configMap.get(place.getNumeroPlace());
            result.add(toEventPlaceConfigDTO(place, config));
        }
        return result;
    }

    // ========== Direct place pricing (modifies Place entity) ==========

    // tarification directe par rangee
    @Transactional
    public int applyRowPricingDirect(Integer eventId, PlaceDTO.RowPricingRequest request) {
        log.debug("Applying row pricing for event {} rang '{}': type={}, prix={}",
                eventId, request.getRang(), request.getTypePlace(), request.getPrix());

        evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Place> places = placeRepository.findPlacesForEventLocation(eventId);
        int updated = 0;

        for (Place place : places) {
            if (request.getRang().equals(place.getRange())) {
                place.setTypePlace(request.getTypePlace());
                if (request.getPrix() != null) {
                    place.setPrix(request.getPrix());
                }
                placeRepository.save(place);
                updated++;
            }
        }

        log.info("Row pricing applied: {} places updated for rang '{}'", updated, request.getRang());
        return updated;
    }

    // mise a jour directe du prix d'une place
    @Transactional
    public PlaceDTO updatePlacePricingDirect(String numeroPlace, String typePlace, BigDecimal prix) {
        log.debug("Updating pricing for place {}: type={}, prix={}", numeroPlace, typePlace, prix);

        Place place = placeRepository.findByNumeroPlace(numeroPlace)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numeroPlace));

        if (typePlace != null) place.setTypePlace(typePlace);
        if (prix != null) place.setPrix(prix);

        Place saved = placeRepository.save(place);
        log.info("Place pricing updated: {}", numeroPlace);
        return toPlaceDTO(saved);
    }

    // places d'un evenement
    @Transactional(readOnly = true)
    public List<PlaceDTO> getPlacesForEvent(Integer eventId) {
        return placeRepository.findPlacesForEventLocation(eventId)
                .stream()
                .map(this::toPlaceDTO)
                .collect(Collectors.toList());
    }

    // ========== Event-specific pricing (via EvenementPlaceConfiguration) ==========

    // tarification par rangee avec configuration
    @Transactional
    public int applyRowPricingWithConfig(Integer eventId, String rang, String typePlace, BigDecimal prix) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Place> places;
        if (event.getLieu() != null) {
            places = placeRepository.findPlacesForEventLocation(eventId);
        } else {
            throw new BadRequestException("Event has no associated venue");
        }

        List<Place> rowPlaces = places.stream()
                .filter(p -> rang.equals(p.getRange()))
                .collect(Collectors.toList());

        int updated = 0;
        Evenement finalEvent = event;
        for (Place place : rowPlaces) {
            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, place.getNumeroPlace())
                    .orElseGet(() -> {
                        EvenementPlaceConfiguration newConfig = new EvenementPlaceConfiguration();
                        newConfig.setEvenement(finalEvent);
                        newConfig.setPlace(place);
                        return newConfig;
                    });

            config.setTypePlaceOverride(typePlace);
            if (prix != null) {
                config.setPrixOverride(prix);
            }
            configRepository.save(config);
            updated++;
        }
        log.info("Row pricing applied for event {} rang '{}': {} places updated", eventId, rang, updated);
        return updated;
    }

    // mise a jour du prix avec configuration
    @Transactional
    public EvenementDTO.EventPlaceConfig updatePlacePricingWithConfig(Integer eventId, String numeroPlace,
                                                   String typePlace, BigDecimal prix) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        Place place = placeRepository.findByNumeroPlace(numeroPlace)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numeroPlace));

        EvenementPlaceConfiguration config = configRepository
                .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, numeroPlace)
                .orElseGet(() -> {
                    EvenementPlaceConfiguration newConfig = new EvenementPlaceConfiguration();
                    newConfig.setEvenement(event);
                    newConfig.setPlace(place);
                    return newConfig;
                });

        if (typePlace != null) config.setTypePlaceOverride(typePlace);
        if (prix != null) config.setPrixOverride(prix);
        configRepository.save(config);

        log.info("Place pricing updated for event {} place {}", eventId, numeroPlace);
        return toEventPlaceConfigDTO(place, config);
    }

    // recherche de places
    @Transactional(readOnly = true)
    public List<EvenementDTO.EventPlaceConfig> searchPlaces(Integer eventId, String query, String typeFilter) {
        if (typeFilter != null && !typeFilter.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .findByEventAndTypePlace(eventId, typeFilter);
            return configs.stream()
                    .map(c -> toEventPlaceConfigDTO(c.getPlace(), c))
                    .collect(Collectors.toList());
        }
        if (query != null && !query.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .searchByEventAndQuery(eventId, query);
            return configs.stream()
                    .map(c -> toEventPlaceConfigDTO(c.getPlace(), c))
                    .collect(Collectors.toList());
        }
        return getPlacesWithConfig(eventId, null);
    }

    // tarification par type de place
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
            config.setPrixOverride(prix);
            configRepository.save(config);
            updated++;
        }
        log.info("Type pricing applied for event {} type '{}': {} places updated", eventId, typePlace, updated);
        return updated;
    }

    // affectation du type aux places
    @Transactional
    public int assignTypeToPlaces(Integer eventId, String typePlace,
                                   List<String> placeIds, List<String> rows) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));

        List<Place> allPlaces;
        if (event.getLieu() != null) {
            allPlaces = placeRepository.findPlacesForEventLocation(eventId);
        } else {
            throw new BadRequestException("Event has no associated venue");
        }

        List<Place> targetPlaces = allPlaces.stream()
                .filter(p -> {
                    boolean matchPlace = placeIds != null && placeIds.contains(p.getNumeroPlace());
                    boolean matchRow = rows != null && rows.contains(p.getRange());
                    return matchPlace || matchRow;
                })
                .collect(Collectors.toList());

        if (targetPlaces.isEmpty()) {
            log.warn("No places match the selection for event {}", eventId);
            return 0;
        }

        int updated = 0;
        for (Place place : targetPlaces) {
            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, place.getNumeroPlace())
                    .orElseGet(() -> {
                        EvenementPlaceConfiguration newConfig = new EvenementPlaceConfiguration();
                        newConfig.setEvenement(event);
                        newConfig.setPlace(place);
                        return newConfig;
                    });
            config.setTypePlaceOverride(typePlace);
            configRepository.save(config);
            updated++;
        }
        log.info("Type assigned for event {}: {} places → '{}'", eventId, updated, typePlace);
        return updated;
    }

    // types distincts pour un evenement
    @Transactional(readOnly = true)
    public List<String> getDistinctTypesForEvent(Integer eventId) {
        return configRepository.findByEvenement_IdEvenement(eventId)
                .stream()
                .map(EvenementPlaceConfiguration::getTypePlaceOverride)
                .distinct()
                .sorted()
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
        dto.setRange(place.getRange());
        dto.setTypePlace(place.getTypePlace());
        dto.setPrix(place.getPrix());
        dto.setNumeroSalle(place.getSalle().getNumeroSalle());
        dto.setStatut(place.getStatut().name());
        return dto;
    }

    private EvenementDTO.EventPlaceConfig toEventPlaceConfigDTO(Place place, EvenementPlaceConfiguration config) {
        EvenementDTO.EventPlaceConfig dto = new EvenementDTO.EventPlaceConfig();
        dto.setNumeroPlace(place.getNumeroPlace());
        dto.setRange(place.getRange());
        dto.setTypePlace(place.getTypePlace());
        dto.setPrix(place.getPrix());
        dto.setStatut(place.getStatut().name());
        dto.setNumeroSalle(place.getSalle().getNumeroSalle());
        dto.setNomSalle(place.getSalle().getNomSalle());
        if (config != null) {
            dto.setTypePlaceOverride(config.getTypePlaceOverride());
            dto.setPrixOverride(config.getPrixOverride());
            dto.setStatutPlace(config.getStatutPlace());
        }
        return dto;
    }
}
