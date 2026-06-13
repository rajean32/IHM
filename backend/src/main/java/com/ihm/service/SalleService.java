package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.SalleDTO;
import com.ihm.repository.ConcernerRepository;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.LieuRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.model.Lieu;
import com.ihm.model.Place;
import com.ihm.model.Salle;
import com.ihm.model.SalleTypeEvenement;
import com.ihm.model.TypeAgencement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SalleService {

    private static final Logger log = LoggerFactory.getLogger(SalleService.class);

    private final SalleRepository salleRepository;
    private final LieuRepository lieuRepository;
    private final PlaceRepository placeRepository;
    private final ConcernerRepository concernerRepository;
    private final EvenementPlaceConfigurationRepository configRepository;

    public SalleService(SalleRepository salleRepository, LieuRepository lieuRepository,
                        PlaceRepository placeRepository, ConcernerRepository concernerRepository,
                        EvenementPlaceConfigurationRepository configRepository) {
        this.salleRepository = salleRepository;
        this.lieuRepository = lieuRepository;
        this.placeRepository = placeRepository;
        this.concernerRepository = concernerRepository;
        this.configRepository = configRepository;
    }

    @Transactional(readOnly = true)
    public List<SalleDTO> getAll() {
        log.debug("Fetching all rooms");
        return salleRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SalleDTO getById(String numero) {
        log.debug("Fetching room by numero: {}", numero);
        Salle salle = salleRepository.findByNumeroSalle(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numero));
        return toDTO(salle);
    }

    @Transactional(readOnly = true)
    public List<SalleDTO> getByLieu(String codeLieu) {
        return salleRepository.findByLieu_Code(codeLieu)
                .stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<SalleDTO> getCompatibleSalles(String codeLieu, String codeCategorie) {
        return salleRepository.findCompatibleSalles(codeLieu, codeCategorie)
                .stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Transactional
    public SalleDTO create(SalleDTO dto) {
        String lieuId = dto.getCodeLieu() != null ? dto.getCodeLieu() : dto.getIdLieu();
        log.info("--- Création salle --- nom={}, lieuId={}, range={}", dto.getNomSalle(), lieuId, dto.getRange());
        Lieu lieu = lieuRepository.findById(lieuId)
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "codeLieu", lieuId));
        log.info("Lieu trouvé: code={}, nom={}", lieu.getCode(), lieu.getNomLieu());
        String base = generateNumeroSalle(lieu.getCode(), dto.getNomSalle());
        String numeroSalle = base;
        int counter = 1;
        while (salleRepository.existsByNumeroSalle(numeroSalle)) {
            numeroSalle = base + "_" + counter++;
        }
        log.info("NumeroSalle généré: {}", numeroSalle);
        Salle salle = new Salle();
        salle.setNumeroSalle(numeroSalle);
        salle.setNomSalle(dto.getNomSalle());
        salle.setType(dto.getType());
        salle.setCapacite(dto.getCapacite());
        salle.setRange(dto.getRange());
        salle.setTypeAgencement(dto.getTypeAgencement() != null ? dto.getTypeAgencement() : TypeAgencement.UNIQUEMENT_ASSIS);
        salle.setLieu(lieu);
        Salle saved = salleRepository.save(salle);
        log.info("Salle créée avec succès: numeroSalle={}, nom={}, lieu={}, range={}",
                saved.getNumeroSalle(), saved.getNomSalle(), saved.getLieu().getNomLieu(), saved.getRange());
        return toDTO(saved);
    }

    private String generateNumeroSalle(String codeLieu, String nomSalle) {
        String slug = nomSalle.toUpperCase()
                .replaceAll("\\s+", "_")
                .replaceAll("[^A-Z0-9_]", "");
        return codeLieu + "_" + slug;
    }

    @Transactional
    public SalleDTO update(String numero, SalleDTO dto) {
        log.debug("Updating room: {}", numero);
        Salle salle = salleRepository.findByNumeroSalle(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numero));
        if (dto.getNomSalle() != null) salle.setNomSalle(dto.getNomSalle());
        if (dto.getType() != null) salle.setType(dto.getType());
        if (dto.getCapacite() != null) salle.setCapacite(dto.getCapacite());
        if (dto.getRange() != null)         salle.setRange(dto.getRange());
        if (dto.getTypeAgencement() != null) salle.setTypeAgencement(dto.getTypeAgencement());
        if (dto.getCodeLieu() != null) {
            Lieu lieu = lieuRepository.findById(dto.getCodeLieu())
                    .orElseThrow(() -> new ResourceNotFoundException("Lieu", "codeLieu", dto.getCodeLieu()));
            salle.setLieu(lieu);
        }
        Salle saved = salleRepository.save(salle);
        log.info("Room updated: {}", numero);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String numero) {
        log.debug("Deleting room: {}", numero);
        Salle salle = salleRepository.findByNumeroSalle(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numero));
        List<Place> places = placeRepository.findBySalle_NumeroSalle(numero);
        List<String> placeIds = places.stream().map(Place::getNumeroPlace).collect(Collectors.toList());
        if (!placeIds.isEmpty()) {
            concernerRepository.deleteByPlaceNumeroPlaceIn(placeIds);
            configRepository.deleteByPlaceNumeroPlaceIn(placeIds);
            placeRepository.deleteAll(places);
        }
        salleRepository.delete(salle);
        log.info("Room deleted: {}", numero);
    }

    @Transactional
    public int deleteBatch(List<String> numeros) {
        log.debug("Deleting {} rooms", numeros.size());
        int deleted = 0;
        for (String numero : numeros) {
            if (!salleRepository.existsByNumeroSalle(numero)) {
                log.warn("Room not found, skipping: {}", numero);
                continue;
            }
            List<Place> places = placeRepository.findBySalle_NumeroSalle(numero);
            List<String> placeIds = places.stream().map(Place::getNumeroPlace).collect(Collectors.toList());
            if (!placeIds.isEmpty()) {
                concernerRepository.deleteByPlaceNumeroPlaceIn(placeIds);
                configRepository.deleteByPlaceNumeroPlaceIn(placeIds);
                placeRepository.deleteAll(places);
            }
            salleRepository.deleteById(numero);
            deleted++;
        }
        log.info("{} rooms deleted successfully", deleted);
        return deleted;
    }

    private SalleDTO toDTO(Salle salle) {
        SalleDTO dto = new SalleDTO();
        dto.setNumeroSalle(salle.getNumeroSalle());
        dto.setNomSalle(salle.getNomSalle());
        dto.setType(salle.getType());
        dto.setCapacite(salle.getCapacite());
        dto.setRange(salle.getRange());
        dto.setTypeAgencement(salle.getTypeAgencement());
        if (salle.getLieu() != null) {
            dto.setCodeLieu(salle.getLieu().getCode());
            dto.setIdLieu(salle.getLieu().getCode());
            dto.setNomLieu(salle.getLieu().getNomLieu());
        }
        if (salle.getTypesEvenement() != null && !salle.getTypesEvenement().isEmpty()) {
            dto.setTypesEvenement(salle.getTypesEvenement().stream()
                    .map(st -> st.getCategorie().getCodeCategorie())
                    .collect(Collectors.toList()));
        }
        return dto;
    }
}
