package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.ClientDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schemat.Administrateur;
import com.ihm.schemat.Client;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ClientService {

    private static final Logger log = LoggerFactory.getLogger(ClientService.class);

    private final ClientRepository clientRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;

    public ClientService(ClientRepository clientRepository,
                         UtilisateurRepository utilisateurRepository,
                         AdministrateurRepository administrateurRepository,
                         PasswordEncoder passwordEncoder) {
        this.clientRepository = clientRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<ClientDTO> getAll() {
        log.debug("Fetching all clients");
        return clientRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public ClientDTO getById(String code) {
        log.debug("Fetching client by code: {}", code);
        Client client = clientRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", code));
        return toDTO(client);
    }

    @Transactional
    public ClientDTO create(ClientDTO dto) {
        log.debug("Creating client: {}", dto.getEmail());
        if (utilisateurRepository.existsByCodeUtilisateur(dto.getCodeClient())) {
            throw new DuplicateResourceException("Client", "codeClient", dto.getCodeClient());
        }
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("Client", "email", dto.getEmail());
        }
        Client client = new Client();
        client.setCodeUtilisateur(dto.getCodeClient());
        client.setNom(dto.getNom());
        client.setPrenoms(dto.getPrenoms());
        client.setSexe(dto.getSexe());
        client.setDateDeNaissance(dto.getDateDeNaissance());
        client.setEmail(dto.getEmail());
        client.setTel(dto.getTel());
        client.setMotDePasse(passwordEncoder.encode("default123"));
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            client.setAdministrateur(admin);
        }
        Client saved = clientRepository.save(client);
        log.info("Client created: {}", saved.getCodeUtilisateur());
        return toDTO(saved);
    }

    @Transactional
    public ClientDTO update(String code, ClientDTO dto) {
        log.debug("Updating client: {}", code);
        Client client = clientRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", code));
        if (dto.getNom() != null) client.setNom(dto.getNom());
        if (dto.getPrenoms() != null) client.setPrenoms(dto.getPrenoms());
        if (dto.getSexe() != null) client.setSexe(dto.getSexe());
        if (dto.getDateDeNaissance() != null) client.setDateDeNaissance(dto.getDateDeNaissance());
        if (dto.getEmail() != null) {
            if (!client.getEmail().equals(dto.getEmail()) && utilisateurRepository.existsByEmail(dto.getEmail())) {
                throw new DuplicateResourceException("Client", "email", dto.getEmail());
            }
            client.setEmail(dto.getEmail());
        }
        if (dto.getTel() != null) client.setTel(dto.getTel());
        if (dto.getCodeAdministrateur() != null) {
            Administrateur admin = administrateurRepository.findByCodeAdministrateur(dto.getCodeAdministrateur())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur()));
            client.setAdministrateur(admin);
        }
        Client saved = clientRepository.save(client);
        log.info("Client updated: {}", code);
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting client: {}", code);
        if (!clientRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Client", "codeClient", code);
        }
        clientRepository.deleteById(code);
        log.info("Client deleted: {}", code);
    }

    private ClientDTO toDTO(Client client) {
        ClientDTO dto = new ClientDTO();
        dto.setCodeClient(client.getCodeUtilisateur());
        dto.setNom(client.getNom());
        dto.setPrenoms(client.getPrenoms());
        dto.setSexe(client.getSexe());
        dto.setDateDeNaissance(client.getDateDeNaissance());
        dto.setEmail(client.getEmail());
        dto.setTel(client.getTel());
        if (client.getAdministrateur() != null) {
            dto.setCodeAdministrateur(client.getAdministrateur().getCodeAdministrateur());
        }
        return dto;
    }
}
