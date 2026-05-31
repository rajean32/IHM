package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.EventPlaceConfigDTO;
import com.ihm.model.dto.RowPricingRequest;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.schemat.Evenement;
import com.ihm.schemat.EvenementPlaceConfiguration;
import com.ihm.schemat.Place;
import com.ihm.schemat.Salle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class EventPricingService {

    private static final Logger log = LoggerFactory.getLogger(EventPricingService.class);

    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final SalleRepository salleRepository;
    private final EvenementPlaceConfigurationRepository configRepository;

    public EventPricingService(EvenementRepository evenementRepository,
                               PlaceRepository placeRepository,
                               SalleRepository salleRepository,
                               EvenementPlaceConfigurationRepository configRepository) {
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.salleRepository = salleRepository;
        this.configRepository = configRepository;
    }

    @Transactional(readOnly = true)
    public List<Salle> getSallesForEvent(Integer eventId) {
        Evenement event = evenementRepository.findByIdEvenement(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", eventId));
        if (event.getLieu() == null) {
            throw new BadRequestException("Event has no associated venue");
        }
        return salleRepository.findByLieu_IdLieu(event.getLieu().getIdLieu());
    }

    @Transactional(readOnly = true)
    public List<String> getDistinctRangsForSalle(String numeroSalle) {
        return placeRepository.findBySalle_NumeroSalle(numeroSalle)
                .stream()
                .map(Place::getRange)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EventPlaceConfigDTO> getPlacesWithConfig(Integer eventId, String numeroSalle) {
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

        List<EventPlaceConfigDTO> result = new ArrayList<>();
        for (Place place : places) {
            EvenementPlaceConfiguration config = configMap.get(place.getNumeroPlace());
            result.add(toDTO(place, config));
        }
        return result;
    }

    @Transactional
    public int applyRowPricing(Integer eventId, String rang, String typePlace, BigDecimal prix) {
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
        for (Place place : rowPlaces) {
            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(eventId, place.getNumeroPlace())
                    .orElseGet(() -> {
                        EvenementPlaceConfiguration newConfig = new EvenementPlaceConfiguration();
                        newConfig.setEvenement(event);
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

    @Transactional
    public EventPlaceConfigDTO updatePlacePricing(Integer eventId, String numeroPlace,
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
        return toDTO(place, config);
    }

    @Transactional(readOnly = true)
    public List<EventPlaceConfigDTO> searchPlaces(Integer eventId, String query, String typeFilter) {
        if (typeFilter != null && !typeFilter.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .findByEventAndTypePlace(eventId, typeFilter);
            return configs.stream()
                    .map(c -> toDTO(c.getPlace(), c))
                    .collect(Collectors.toList());
        }
        if (query != null && !query.isBlank()) {
            List<EvenementPlaceConfiguration> configs = configRepository
                    .searchByEventAndQuery(eventId, query);
            return configs.stream()
                    .map(c -> toDTO(c.getPlace(), c))
                    .collect(Collectors.toList());
        }
        return getPlacesWithConfig(eventId, null);
    }

    @Transactional(readOnly = true)
    public List<String> getDistinctTypesForEvent(Integer eventId) {
        return configRepository.findByEvenement_IdEvenement(eventId)
                .stream()
                .map(EvenementPlaceConfiguration::getTypePlaceOverride)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    private EventPlaceConfigDTO toDTO(Place place, EvenementPlaceConfiguration config) {
        EventPlaceConfigDTO dto = new EventPlaceConfigDTO();
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
