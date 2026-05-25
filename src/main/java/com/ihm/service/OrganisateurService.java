package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.OrganisateurDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schemat.Administrateur;
import com.ihm.schemat.Organisateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrganisateurService {

    private static final Logger log = LoggerFactory.getLogger(OrganisateurService.class);

    private final OrganisateurRepository organisateurRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;

    public OrganisateurService(OrganisateurRepository organisateurRepository,
                               UtilisateurRepository utilisateurRepository,
                               AdministrateurRepository administrateurRepository,
                               PasswordEncoder passwordEncoder) {
        this.organisateurRepository = organisateurRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<OrganisateurDTO> getAll() {
        log.debug("Fetching all organisateurs");
        return organisateurRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public OrganisateurDTO getById(String code) {
        log.debug("Fetching organisateur by code: {}", code);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", code));
        return toDTO(org);
    }

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
        return toDTO(saved);
    }

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
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting organisateur: {}", code);
        if (!organisateurRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Organisateur", "codeOrganisateur", code);
        }
        organisateurRepository.deleteById(code);
        log.info("Organisateur deleted: {}", code);
    }

    private OrganisateurDTO toDTO(Organisateur org) {
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
}
