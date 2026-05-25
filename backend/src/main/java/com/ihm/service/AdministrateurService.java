package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.AdministrateurDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.schemat.Administrateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AdministrateurService {

    private static final Logger log = LoggerFactory.getLogger(AdministrateurService.class);

    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;

    public AdministrateurService(AdministrateurRepository administrateurRepository,
                                 PasswordEncoder passwordEncoder) {
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<AdministrateurDTO> getAll() {
        log.debug("Fetching all administrators");
        return administrateurRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public AdministrateurDTO getById(String code) {
        log.debug("Fetching administrator by code: {}", code);
        Administrateur admin = administrateurRepository.findByCodeAdministrateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", code));
        return toDTO(admin);
    }

    @Transactional
    public AdministrateurDTO create(AdministrateurDTO dto) {
        log.debug("Creating administrator: {}", dto.getCodeAdministrateur());
        if (administrateurRepository.existsByCodeAdministrateur(dto.getCodeAdministrateur())) {
            throw new DuplicateResourceException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur());
        }
        Administrateur admin = new Administrateur(dto.getCodeAdministrateur(), passwordEncoder.encode(dto.getMotdepasseAdministrateur()));
        Administrateur saved = administrateurRepository.save(admin);
        log.info("Administrator created: {}", saved.getCodeAdministrateur());
        return toDTO(saved);
    }

    @Transactional
    public AdministrateurDTO update(String code, AdministrateurDTO dto) {
        log.debug("Updating administrator: {}", code);
        Administrateur admin = administrateurRepository.findByCodeAdministrateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", code));
        if (dto.getMotdepasseAdministrateur() != null) {
            admin.setMotdepasseAdministrateur(passwordEncoder.encode(dto.getMotdepasseAdministrateur()));
        }
        Administrateur saved = administrateurRepository.save(admin);
        log.info("Administrator updated: {}", code);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting administrator: {}", code);
        if (!administrateurRepository.existsByCodeAdministrateur(code)) {
            throw new ResourceNotFoundException("Administrateur", "codeAdministrateur", code);
        }
        administrateurRepository.deleteById(code);
        log.info("Administrator deleted: {}", code);
    }

    private AdministrateurDTO toDTO(Administrateur admin) {
        AdministrateurDTO dto = new AdministrateurDTO();
        dto.setCodeAdministrateur(admin.getCodeAdministrateur());
        dto.setMotdepasseAdministrateur(admin.getMotdepasseAdministrateur());
        return dto;
    }
}
