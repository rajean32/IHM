package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.PlaceDTO;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.model.Lieu;
import com.ihm.model.Place;
import com.ihm.model.Salle;
import com.ihm.model.StatutPlace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
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

    private String buildCombinedKey(Salle salle, String rang, String seatNumber) {
        Lieu lieu = salle.getLieu();
        String lieuId = lieu != null ? lieu.getCode() : "?";
        return lieuId + "-" + salle.getNumeroSalle() + "-" + rang + "-" + seatNumber;
    }

    // recuperation de toutes les places
    public List<PlaceDTO> getAll() {
        log.debug("Fetching all places");
        return placeRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // places d'une salle
    public List<PlaceDTO> getBySalle(String numeroSalle) {
        log.debug("Fetching places by salle: {}", numeroSalle);
        return placeRepository.findBySalle_NumeroSalle(numeroSalle)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'une place par son numero
    public PlaceDTO getById(String numero) {
        log.debug("Fetching place by numero: {}", numero);
        Place place = placeRepository.findByNumeroPlace(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numero));
        return toDTO(place);
    }

    // creation d'une place
    @Transactional
    public PlaceDTO create(PlaceDTO dto) {
        Salle salle = salleRepository.findByNumeroSalle(dto.getNumeroSalle())
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", dto.getNumeroSalle()));

        String rang = dto.getRange() != null ? dto.getRange() : "?";
        String seatNum = dto.getNumeroPlace() != null ? dto.getNumeroPlace().replaceAll(".*-", "") : "?";
        String combinedKey = buildCombinedKey(salle, rang, seatNum);

        if (placeRepository.existsByNumeroPlace(combinedKey)) {
            log.warn("Place already exists, skipping: {}", combinedKey);
            throw new DuplicateResourceException("Place", "numeroPlace", combinedKey);
        }

        log.debug("Creating place with combined key: {}", combinedKey);
        Place place = new Place();
        place.setNumeroPlace(combinedKey);
        place.setRange(rang);
        place.setTypePlace(dto.getTypePlace());
        place.setPrix(dto.getPrix());
        place.setStatut(dto.getStatut() != null ? StatutPlace.valueOf(dto.getStatut()) : StatutPlace.DISPONIBLE);
        place.setSalle(salle);
        Place saved = placeRepository.save(place);
        log.info("Place created: {}", saved.getNumeroPlace());
        return toDTO(saved);
    }

    // creation par lot de places
    @Transactional
    public List<PlaceDTO> createBatch(PlaceDTO.BatchPlaceRequest request) {
        log.debug("Batch creating places for salle: {}", request.getNumeroSalle());
        Salle salle = salleRepository.findByNumeroSalle(request.getNumeroSalle())
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", request.getNumeroSalle()));

        List<PlaceDTO> created = new ArrayList<>();
        String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        for (int r = 0; r < request.getNombreRangees(); r++) {
            String rang = request.getPrefixeRangee() + (r < 26 ? String.valueOf(letters.charAt(r)) : "R" + r);
            for (int s = 0; s < request.getPlacesParRangee(); s++) {
                int num = request.getDebutNumero() + s;
                String combinedKey = buildCombinedKey(salle, rang, String.valueOf(num));
                if (placeRepository.existsByNumeroPlace(combinedKey)) {
                    log.warn("Place already exists, skipping: {}", combinedKey);
                    continue;
                }
                Place place = new Place();
                place.setNumeroPlace(combinedKey);
                place.setRange(rang);
                place.setTypePlace(request.getTypePlace());
                place.setPrix(request.getPrix());
                place.setStatut(StatutPlace.DISPONIBLE);
                place.setSalle(salle);
                Place saved = placeRepository.save(place);
                created.add(toDTO(saved));
            }
        }
        log.info("Batch created {} places for salle: {}", created.size(), request.getNumeroSalle());
        return created;
    }

    // mise a jour d'une place
    @Transactional
    public PlaceDTO update(String numero, PlaceDTO dto) {
        log.debug("Updating place: {}", numero);
        Place place = placeRepository.findByNumeroPlace(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", numero));
        if (dto.getRange() != null) place.setRange(dto.getRange());
        if (dto.getTypePlace() != null) place.setTypePlace(dto.getTypePlace());
        if (dto.getPrix() != null) place.setPrix(dto.getPrix());
        if (dto.getStatut() != null) place.setStatut(StatutPlace.valueOf(dto.getStatut()));
        if (dto.getNumeroSalle() != null) {
            Salle salle = salleRepository.findByNumeroSalle(dto.getNumeroSalle())
                    .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", dto.getNumeroSalle()));
            place.setSalle(salle);
        }
        Place saved = placeRepository.save(place);
        log.info("Place updated: {}", numero);
        return toDTO(saved);
    }

    // suppression d'une place
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
        dto.setPrix(place.getPrix());
        dto.setStatut(place.getStatut() != null ? place.getStatut().name() : StatutPlace.DISPONIBLE.name());
        dto.setNumeroSalle(place.getSalle() != null ? place.getSalle().getNumeroSalle() : null);
        return dto;
    }
}
