package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.SalleDTO;
import com.ihm.repository.LieuRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.schemat.Lieu;
import com.ihm.schemat.Salle;
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

    public SalleService(SalleRepository salleRepository, LieuRepository lieuRepository) {
        this.salleRepository = salleRepository;
        this.lieuRepository = lieuRepository;
    }

    public List<SalleDTO> getAll() {
        log.debug("Fetching all rooms");
        return salleRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public SalleDTO getById(String numero) {
        log.debug("Fetching room by numero: {}", numero);
        Salle salle = salleRepository.findByNumeroSalle(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numero));
        return toDTO(salle);
    }

    @Transactional
    public SalleDTO create(SalleDTO dto) {
        log.debug("Creating room: {}", dto.getNumeroSalle());
        if (salleRepository.existsByNumeroSalle(dto.getNumeroSalle())) {
            throw new DuplicateResourceException("Salle", "numeroSalle", dto.getNumeroSalle());
        }
        Lieu lieu = lieuRepository.findByIdLieu(dto.getIdLieu())
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", dto.getIdLieu()));
        Salle salle = new Salle();
        salle.setNumeroSalle(dto.getNumeroSalle());
        salle.setNomSalle(dto.getNomSalle());
        salle.setLieu(lieu);
        Salle saved = salleRepository.save(salle);
        log.info("Room created: {}", saved.getNumeroSalle());
        return toDTO(saved);
    }

    @Transactional
    public SalleDTO update(String numero, SalleDTO dto) {
        log.debug("Updating room: {}", numero);
        Salle salle = salleRepository.findByNumeroSalle(numero)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numero));
        if (dto.getNomSalle() != null) salle.setNomSalle(dto.getNomSalle());
        if (dto.getIdLieu() != null) {
            Lieu lieu = lieuRepository.findByIdLieu(dto.getIdLieu())
                    .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", dto.getIdLieu()));
            salle.setLieu(lieu);
        }
        Salle saved = salleRepository.save(salle);
        log.info("Room updated: {}", numero);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String numero) {
        log.debug("Deleting room: {}", numero);
        if (!salleRepository.existsByNumeroSalle(numero)) {
            throw new ResourceNotFoundException("Salle", "numeroSalle", numero);
        }
        salleRepository.deleteById(numero);
        log.info("Room deleted: {}", numero);
    }

    private SalleDTO toDTO(Salle salle) {
        SalleDTO dto = new SalleDTO();
        dto.setNumeroSalle(salle.getNumeroSalle());
        dto.setNomSalle(salle.getNomSalle());
        dto.setIdLieu(salle.getLieu() != null ? salle.getLieu().getIdLieu() : null);
        return dto;
    }
}
