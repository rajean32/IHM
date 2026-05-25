package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.UtilisateurDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schemat.Administrateur;
import com.ihm.schemat.Utilisateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UtilisateurService {

    private static final Logger log = LoggerFactory.getLogger(UtilisateurService.class);

    private final UtilisateurRepository utilisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;

    public UtilisateurService(UtilisateurRepository utilisateurRepository,
                              AdministrateurRepository administrateurRepository,
                              PasswordEncoder passwordEncoder) {
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<UtilisateurDTO> getAll() {
        log.debug("Fetching all users");
        return utilisateurRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public UtilisateurDTO getById(String code) {
        log.debug("Fetching user by code: {}", code);
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));
        return toDTO(user);
    }

    @Transactional
    public UtilisateurDTO create(UtilisateurDTO dto) {
        log.debug("Creating user: {}", dto.getEmail());
        if (utilisateurRepository.existsByCodeUtilisateur(dto.getCodeUtilisateur())) {
            throw new DuplicateResourceException("Utilisateur", "codeUtilisateur", dto.getCodeUtilisateur());
        }
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("Utilisateur", "email", dto.getEmail());
        }
        Utilisateur user = new Utilisateur();
        user.setCodeUtilisateur(dto.getCodeUtilisateur());
        user.setNom(dto.getNom());
        user.setPrenoms(dto.getPrenoms());
        user.setSexe(dto.getSexe());
        user.setDateDeNaissance(dto.getDateDeNaissance());
        user.setEmail(dto.getEmail());
        user.setTel(dto.getTel());
        user.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            user.setAdministrateur(admin);
        }
        Utilisateur saved = utilisateurRepository.save(user);
        log.info("User created: {}", saved.getCodeUtilisateur());
        return toDTO(saved);
    }

    @Transactional
    public UtilisateurDTO update(String code, UtilisateurDTO dto) {
        log.debug("Updating user: {}", code);
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));
        if (dto.getNom() != null) user.setNom(dto.getNom());
        if (dto.getPrenoms() != null) user.setPrenoms(dto.getPrenoms());
        if (dto.getSexe() != null) user.setSexe(dto.getSexe());
        if (dto.getDateDeNaissance() != null) user.setDateDeNaissance(dto.getDateDeNaissance());
        if (dto.getEmail() != null) {
            if (!user.getEmail().equals(dto.getEmail()) && utilisateurRepository.existsByEmail(dto.getEmail())) {
                throw new DuplicateResourceException("Utilisateur", "email", dto.getEmail());
            }
            user.setEmail(dto.getEmail());
        }
        if (dto.getTel() != null) user.setTel(dto.getTel());
        if (dto.getMotDePasse() != null) user.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            user.setAdministrateur(admin);
        }
        Utilisateur saved = utilisateurRepository.save(user);
        log.info("User updated: {}", code);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting user: {}", code);
        if (!utilisateurRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code);
        }
        utilisateurRepository.deleteById(code);
        log.info("User deleted: {}", code);
    }

    private UtilisateurDTO toDTO(Utilisateur user) {
        UtilisateurDTO dto = new UtilisateurDTO();
        dto.setCodeUtilisateur(user.getCodeUtilisateur());
        dto.setNom(user.getNom());
        dto.setPrenoms(user.getPrenoms());
        dto.setSexe(user.getSexe());
        dto.setDateDeNaissance(user.getDateDeNaissance());
        dto.setEmail(user.getEmail());
        dto.setTel(user.getTel());
        if (user.getAdministrateur() != null) {
            dto.setCodeAdministrateur(user.getAdministrateur().getCodeAdministrateur());
        }
        return dto;
    }
}
