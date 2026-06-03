package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.ClientDTO;
import com.ihm.repository.*;
import com.ihm.model.*;
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
    private final TicketRepository ticketRepository;
    private final ConcernerRepository concernerRepository;

    public ClientService(ClientRepository clientRepository,
                         UtilisateurRepository utilisateurRepository,
                         AdministrateurRepository administrateurRepository,
                         PasswordEncoder passwordEncoder,
                         TicketRepository ticketRepository,
                         ConcernerRepository concernerRepository) {
        this.clientRepository = clientRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.ticketRepository = ticketRepository;
        this.concernerRepository = concernerRepository;
    }

    // recuperation de tous les clients
    public List<ClientDTO> getAll() {
        log.debug("Fetching all clients");
        return clientRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un client
    public ClientDTO getById(String code) {
        log.debug("Fetching client by code: {}", code);
        Client client = clientRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", code));
        return toDTO(client);
    }

    // creation d'un client
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

    // mise a jour d'un client
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

    // suppression d'un client
    @Transactional
    public void delete(String code) {
        log.debug("Deleting client: {}", code);
        if (!clientRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Client", "codeClient", code);
        }
        clientRepository.deleteById(code);
        log.info("Client deleted: {}", code);
    }

    // tickets d'un client
    @Transactional(readOnly = true)
    public List<ClientDTO.ClientTicket> getClientTickets(String codeClient) {
        log.debug("Fetching tickets for client: {}", codeClient);
        List<Ticket> tickets = ticketRepository.findByCorrespondances_Reservation_Client_CodeUtilisateur(codeClient);
        return tickets.stream().map(ticket -> {
            ClientDTO.ClientTicket dto = new ClientDTO.ClientTicket();
            dto.setCodeTicket(ticket.getCodeTicket());
            dto.setPrix(ticket.getPrix());
            List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ticket.getCodeTicket());
            if (!concerners.isEmpty()) {
                Concerner c = concerners.get(0);
                dto.setEvenementTitre(c.getEvenement().getTitre());
                dto.setDateEvenement(c.getEvenement().getDateEvenement());
                dto.setHeureEvenement(c.getEvenement().getHeureEvenement());
                dto.setNumeroPlace(c.getPlace().getNumeroPlace());
                dto.setRang(c.getPlace().getRange());
                dto.setTypePlace(c.getPlace().getTypePlace());
                dto.setStatut(c.getPlace().getStatut().name());
                if (c.getEvenement().getLieu() != null) {
                    dto.setLieuNom(c.getEvenement().getLieu().getNomLieu());
                }
                if (c.getPlace().getSalle() != null) {
                    dto.setSalleNom(c.getPlace().getSalle().getNomSalle());
                }
            }
            return dto;
        }).collect(Collectors.toList());
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
