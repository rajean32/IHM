package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.LieuDTO;
import com.ihm.repository.LieuRepository;
import com.ihm.schemat.Lieu;
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

    public LieuService(LieuRepository lieuRepository) {
        this.lieuRepository = lieuRepository;
    }

    public List<LieuDTO> getAll() {
        log.debug("Fetching all locations");
        return lieuRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public LieuDTO getById(Integer id) {
        log.debug("Fetching location by id: {}", id);
        Lieu lieu = lieuRepository.findByIdLieu(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", id));
        return toDTO(lieu);
    }

    @Transactional
    public LieuDTO create(LieuDTO dto) {
        log.debug("Creating location: {}", dto.getNomLieu());
        Lieu lieu = new Lieu();
        lieu.setNomLieu(dto.getNomLieu());
        lieu.setAdresse(dto.getAdresse());
        lieu.setVille(dto.getVille());
        Lieu saved = lieuRepository.save(lieu);
        log.info("Location created: id={}", saved.getIdLieu());
        return toDTO(saved);
    }

    @Transactional
    public LieuDTO update(Integer id, LieuDTO dto) {
        log.debug("Updating location: {}", id);
        Lieu lieu = lieuRepository.findByIdLieu(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", id));
        if (dto.getNomLieu() != null) lieu.setNomLieu(dto.getNomLieu());
        if (dto.getAdresse() != null) lieu.setAdresse(dto.getAdresse());
        if (dto.getVille() != null) lieu.setVille(dto.getVille());
        Lieu saved = lieuRepository.save(lieu);
        log.info("Location updated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting location: {}", id);
        if (!lieuRepository.existsByIdLieu(id)) {
            throw new ResourceNotFoundException("Lieu", "idLieu", id);
        }
        lieuRepository.deleteById(id);
        log.info("Location deleted: id={}", id);
    }

    private LieuDTO toDTO(Lieu lieu) {
        LieuDTO dto = new LieuDTO();
        dto.setIdLieu(lieu.getIdLieu());
        dto.setNomLieu(lieu.getNomLieu());
        dto.setAdresse(lieu.getAdresse());
        dto.setVille(lieu.getVille());
        return dto;
    }
}
