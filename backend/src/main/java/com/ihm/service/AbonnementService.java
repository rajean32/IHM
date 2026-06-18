package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Abonnement;
import com.ihm.repository.AbonnementRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.schema.AbonnementDTO;
import com.ihm.schema.EvenementDTO;
import com.ihm.service.EvenementService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AbonnementService {

    private static final Logger log = LoggerFactory.getLogger(AbonnementService.class);

    private final AbonnementRepository abonnementRepository;
    private final ClientRepository clientRepository;
    private final OrganisateurRepository organisateurRepository;
    private final EvenementService evenementService;

    public AbonnementService(AbonnementRepository abonnementRepository,
                             ClientRepository clientRepository,
                             OrganisateurRepository organisateurRepository,
                             EvenementService evenementService) {
        this.abonnementRepository = abonnementRepository;
        this.clientRepository = clientRepository;
        this.organisateurRepository = organisateurRepository;
        this.evenementService = evenementService;
    }

    @Transactional
    public AbonnementDTO subscribe(String codeClient, String codeOrganisateur) {
        if (!clientRepository.existsByCodeUtilisateur(codeClient)) {
            throw new ResourceNotFoundException("Client", "codeClient", codeClient);
        }
        if (!organisateurRepository.existsByCodeUtilisateur(codeOrganisateur)) {
            throw new ResourceNotFoundException("Organisateur", "codeOrganisateur", codeOrganisateur);
        }
        if (abonnementRepository.existsByCodeClientAndCodeOrganisateur(codeClient, codeOrganisateur)) {
            throw new BadRequestException("Déjà abonné à cet organisateur");
        }

        Abonnement abonnement = new Abonnement(codeClient, codeOrganisateur);
        Abonnement saved = abonnementRepository.save(abonnement);
        log.info("Client {} subscribed to organizer {}", codeClient, codeOrganisateur);
        return toDTO(saved);
    }

    @Transactional
    public void unsubscribe(String codeClient, String codeOrganisateur) {
        if (!abonnementRepository.existsByCodeClientAndCodeOrganisateur(codeClient, codeOrganisateur)) {
            throw new BadRequestException("Abonnement introuvable");
        }
        abonnementRepository.deleteByCodeClientAndCodeOrganisateur(codeClient, codeOrganisateur);
        log.info("Client {} unsubscribed from organizer {}", codeClient, codeOrganisateur);
    }

    @Transactional(readOnly = true)
    public List<AbonnementDTO> getAbonnements(String codeClient) {
        return abonnementRepository.findByCodeClient(codeClient)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getFeed(String codeClient) {
        List<String> orgCodes = abonnementRepository.findByCodeClient(codeClient)
                .stream()
                .map(Abonnement::getCodeOrganisateur)
                .collect(Collectors.toList());
        if (orgCodes.isEmpty()) return List.of();

        return orgCodes.stream()
                .flatMap(orgCode -> evenementService.getByOrganisateur(orgCode).stream())
                .sorted((a, b) -> {
                    if (a.getDatePublication() == null && b.getDatePublication() == null) return 0;
                    if (a.getDatePublication() == null) return 1;
                    if (b.getDatePublication() == null) return -1;
                    return b.getDatePublication().compareTo(a.getDatePublication());
                })
                .collect(Collectors.toList());
    }

    private AbonnementDTO toDTO(Abonnement abonnement) {
        AbonnementDTO dto = new AbonnementDTO();
        dto.setIdAbonnement(abonnement.getIdAbonnement());
        dto.setCodeClient(abonnement.getCodeClient());
        dto.setCodeOrganisateur(abonnement.getCodeOrganisateur());
        dto.setDateAbonnement(abonnement.getDateAbonnement());
        return dto;
    }
}
