package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.LieuDTO;
import com.ihm.schema.SalleDTO;
import com.ihm.repository.LieuRepository;
import com.ihm.model.Lieu;
import com.ihm.model.Salle;
import com.ihm.model.Ville;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class LieuService {

    private static final Logger log = LoggerFactory.getLogger(LieuService.class);

    private final LieuRepository lieuRepository;
    private final VilleService villeService;

    public LieuService(LieuRepository lieuRepository, VilleService villeService) {
        this.lieuRepository = lieuRepository;
        this.villeService = villeService;
    }

    // recuperation de tous les lieux
    @Transactional(readOnly = true)
    public List<LieuDTO> getAll() {
        log.debug("Fetching all locations");
        return lieuRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LieuDTO> getByVille(String villeNom) {
        log.debug("Fetching locations by city: {}", villeNom);
        return lieuRepository.findByVille_Nom(villeNom)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LieuDTO getById(String code) {
        log.debug("Fetching location by code: {}", code);
        Lieu lieu = lieuRepository.findById(code)
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "code", code));
        return toDTODetail(lieu);
    }

    @Transactional
    public LieuDTO create(LieuDTO dto) {
        log.debug("Creating location: {}", dto.getNomLieu());
        if (dto.getCode() == null || dto.getCode().isBlank()) {
            throw new com.ihm.exception.BadRequestException("Le code du lieu est requis");
        }
        if (lieuRepository.existsById(dto.getCode())) {
            throw new DuplicateResourceException("Lieu", "code", dto.getCode());
        }
        Lieu lieu = new Lieu();
        lieu.setCode(dto.getCode());
        lieu.setNomLieu(dto.getNomLieu());
        lieu.setAdresse(dto.getAdresse());
        if (dto.getVille() != null) {
            lieu.setVille(villeService.resolveOrCreateVille(dto.getVilleCode(), dto.getVille()));
        }
        Lieu saved = lieuRepository.save(lieu);
        log.info("Location created: code={}", saved.getCode());
        return toDTO(saved);
    }

    @Transactional
    public LieuDTO update(String code, LieuDTO dto) {
        log.debug("Updating location: {}", code);
        Lieu lieu = lieuRepository.findById(code)
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "code", code));
        if (dto.getCode() != null && !dto.getCode().equals(lieu.getCode())) {
            if (lieuRepository.existsById(dto.getCode())) {
                throw new DuplicateResourceException("Lieu", "code", dto.getCode());
            }
            lieu.setCode(dto.getCode());
        }
        if (dto.getNomLieu() != null) lieu.setNomLieu(dto.getNomLieu());
        if (dto.getAdresse() != null) lieu.setAdresse(dto.getAdresse());
        if (dto.getVille() != null) {
            lieu.setVille(villeService.resolveOrCreateVille(dto.getVilleCode(), dto.getVille()));
        }
        Lieu saved = lieuRepository.save(lieu);
        log.info("Location updated: code={}", code);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting location: {}", code);
        if (!lieuRepository.existsById(code)) {
            throw new ResourceNotFoundException("Lieu", "code", code);
        }
        lieuRepository.deleteById(code);
        log.info("Location deleted: code={}", code);
    }

    private LieuDTO toDTO(Lieu lieu) {
        LieuDTO dto = new LieuDTO();
        dto.setCode(lieu.getCode());
        dto.setNomLieu(lieu.getNomLieu());
        dto.setAdresse(lieu.getAdresse());
        dto.setDescription(lieu.getDescription());
        dto.setVille(lieu.getVilleNom());
        dto.setVilleCode(lieu.getVilleCode());
        return dto;
    }

    private LieuDTO toDTODetail(Lieu lieu) {
        LieuDTO dto = toDTO(lieu);
        if (lieu.getSalles() != null) {
            dto.setSalles(lieu.getSalles().stream()
                    .map(this::toSalleDTO)
                    .collect(Collectors.toList()));
        }
        return dto;
    }

    private SalleDTO toSalleDTO(Salle salle) {
        SalleDTO dto = new SalleDTO();
        dto.setNumeroSalle(salle.getNumeroSalle());
        dto.setNomSalle(salle.getNomSalle());
        dto.setCodeLieu(salle.getLieu() != null ? salle.getLieu().getCode() : null);
        dto.setTypeAgencement(salle.getTypeAgencement());
        dto.setCapacite(salle.getCapacite());
        return dto;
    }
}
