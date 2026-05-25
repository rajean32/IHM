package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.PlaceDTO;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.schemat.Place;
import com.ihm.schemat.Salle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlaceService {

    private static final Logger log = LoggerFactory.getLogger(PlaceService.class);

    private final PlaceRepository placeRepository;
    private final SalleRepository salleRepository;

    public PlaceService(PlaceRepository placeRepository, SalleRepository salleRepository) {
        this.placeRepository = placeRepository;
        this.salleRepository = salleRepository;
    }

    public List<PlaceDTO> getAll() {
        log.debug("Fetching all places");
        return placeRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PlaceDTO getById(String numero) {
        log.debug("Fetching place by numero: {}", numero);
        Place place = placeRepository.findByNumeroPlace(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numero));
        return toDTO(place);
    }

    @Transactional
    public PlaceDTO create(PlaceDTO dto) {
        log.debug("Creating place: {}", dto.getNumeroPlace());
        if (placeRepository.existsByNumeroPlace(dto.getNumeroPlace())) {
            throw new DuplicateResourceException("Place", "numeroPlace", dto.getNumeroPlace());
        }
        Salle salle = salleRepository.findByNumeroSalle(dto.getNumeroSalle())
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", dto.getNumeroSalle()));
        Place place = new Place();
        place.setNumeroPlace(dto.getNumeroPlace());
        place.setRange(dto.getRange());
        place.setTypePlace(dto.getTypePlace());
        place.setSalle(salle);
        Place saved = placeRepository.save(place);
        log.info("Place created: {}", saved.getNumeroPlace());
        return toDTO(saved);
    }

    @Transactional
    public PlaceDTO update(String numero, PlaceDTO dto) {
        log.debug("Updating place: {}", numero);
        Place place = placeRepository.findByNumeroPlace(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numero));
        if (dto.getRange() != null) place.setRange(dto.getRange());
        if (dto.getTypePlace() != null) place.setTypePlace(dto.getTypePlace());
        if (dto.getNumeroSalle() != null) {
            Salle salle = salleRepository.findByNumeroSalle(dto.getNumeroSalle())
                    .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", dto.getNumeroSalle()));
            place.setSalle(salle);
        }
        Place saved = placeRepository.save(place);
        log.info("Place updated: {}", numero);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String numero) {
        log.debug("Deleting place: {}", numero);
        if (!placeRepository.existsByNumeroPlace(numero)) {
            throw new ResourceNotFoundException("Place", "numeroPlace", numero);
        }
        placeRepository.deleteById(numero);
        log.info("Place deleted: {}", numero);
    }

    private PlaceDTO toDTO(Place place) {
        PlaceDTO dto = new PlaceDTO();
        dto.setNumeroPlace(place.getNumeroPlace());
        dto.setRange(place.getRange());
        dto.setTypePlace(place.getTypePlace());
        dto.setNumeroSalle(place.getSalle() != null ? place.getSalle().getNumeroSalle() : null);
        return dto;
    }
}
