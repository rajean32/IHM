package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.PlaceDTO;
import com.ihm.model.dto.RowPricingRequest;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.schemat.Evenement;
import com.ihm.schemat.Place;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrganizerPricingService {

    private static final Logger log = LoggerFactory.getLogger(OrganizerPricingService.class);

    private final PlaceRepository placeRepository;
    private final EvenementRepository evenementRepository;

    public OrganizerPricingService(PlaceRepository placeRepository,
                                   EvenementRepository evenementRepository) {
        this.placeRepository = placeRepository;
        this.evenementRepository = evenementRepository;
    }

    @Transactional
    public int applyRowPricing(Integer eventId, RowPricingRequest request) {
        log.debug("Applying row pricing for event {} rang '{}': type={}, prix={}",
                eventId, request.getRang(), request.getTypePlace(), request.getPrix());

        Evenement event = evenementRepository.findByIdEvenement(eventId)
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

    @Transactional
    public PlaceDTO updatePlacePricing(String numeroPlace, String typePlace, BigDecimal prix) {
        log.debug("Updating pricing for place {}: type={}, prix={}", numeroPlace, typePlace, prix);

        Place place = placeRepository.findByNumeroPlace(numeroPlace)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numeroPlace));

        if (typePlace != null) place.setTypePlace(typePlace);
        if (prix != null) place.setPrix(prix);

        Place saved = placeRepository.save(place);
        log.info("Place pricing updated: {}", numeroPlace);
        return toDTO(saved);
    }

    @Transactional(readOnly = true)
    public List<PlaceDTO> getPlacesForEvent(Integer eventId) {
        return placeRepository.findPlacesForEventLocation(eventId)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    private PlaceDTO toDTO(Place place) {
        PlaceDTO dto = new PlaceDTO();
        dto.setNumeroPlace(place.getNumeroPlace());
        dto.setRange(place.getRange());
        dto.setTypePlace(place.getTypePlace());
        dto.setPrix(place.getPrix());
        dto.setNumeroSalle(place.getSalle().getNumeroSalle());
        dto.setStatut(place.getStatut().name());
        return dto;
    }
}
