package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.EvenementDTO;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class EvenementService {

    private static final Logger log = LoggerFactory.getLogger(EvenementService.class);

    private final EvenementRepository evenementRepository;
    private final CategorieRepository categorieRepository;
    private final LieuRepository lieuRepository;
    private final OrganisateurRepository organisateurRepository;
    private final ConcernerRepository concernerRepository;
    private final PlaceRepository placeRepository;

    private static final List<String> VALID_STATUSES = List.of("planifie", "en_cours", "termine", "annule", "suspendu", "valide");

    private static final java.util.Map<String, List<String>> ALLOWED_TRANSITIONS = java.util.Map.of(
        "planifie", List.of("en_cours", "termine", "annule", "suspendu", "valide"),
        "en_cours", List.of("termine", "annule", "suspendu"),
        "termine",   List.of(),
        "annule",    List.of(),
        "suspendu",  List.of("valide", "annule"),
        "valide",    List.of("suspendu", "annule")
    );

    public EvenementService(EvenementRepository evenementRepository,
                            CategorieRepository categorieRepository,
                            LieuRepository lieuRepository,
                            OrganisateurRepository organisateurRepository,
                            ConcernerRepository concernerRepository,
                            PlaceRepository placeRepository) {
        this.evenementRepository = evenementRepository;
        this.categorieRepository = categorieRepository;
        this.lieuRepository = lieuRepository;
        this.organisateurRepository = organisateurRepository;
        this.concernerRepository = concernerRepository;
        this.placeRepository = placeRepository;
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getAll() {
        log.debug("Fetching all events");
        return evenementRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public EvenementDTO getById(Integer id) {
        log.debug("Fetching event by id: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        return toDTO(event);
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByOrganisateur(String codeOrg) {
        log.debug("Fetching events by organizer: {}", codeOrg);
        return evenementRepository.findByOrganisateur_CodeUtilisateur(codeOrg)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByCategorie(String codeCat) {
        log.debug("Fetching events by category: {}", codeCat);
        return evenementRepository.findByCategorie_CodeCategorie(codeCat)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EvenementDTO> getByStatut(String statut) {
        log.debug("Fetching events by status: {}", statut);
        return evenementRepository.findByStatut(statut)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public EvenementDTO create(EvenementDTO dto) {
        log.debug("Creating event: {}", dto.getTitre());

        if (dto.getStatut() != null && !VALID_STATUSES.contains(dto.getStatut())) {
            throw new BadRequestException("Invalid status. Valid values: " + VALID_STATUSES);
        }

        Evenement event = new Evenement();
        event.setTitre(dto.getTitre());
        event.setDescription(dto.getDescription());
        event.setDateEvenement(dto.getDateEvenement());
        event.setHeureEvenement(dto.getHeureEvenement());
        event.setImage(dto.getImage());
        event.setStatut(dto.getStatut() != null ? dto.getStatut() : "planifie");

        if (dto.getCodeCategorie() != null) {
            Categorie cat = categorieRepository.findByCodeCategorie(dto.getCodeCategorie())
                    .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", dto.getCodeCategorie()));
            event.setCategorie(cat);
        }
        if (dto.getIdLieu() == null) {
            throw new BadRequestException("Lieu (idLieu) is required to create an event");
        }
        Lieu lieu = lieuRepository.findByIdLieu(dto.getIdLieu())
                .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", dto.getIdLieu()));
        event.setLieu(lieu);
        Organisateur org = organisateurRepository.findByCodeUtilisateur(dto.getCodeOrganisateur())
                .orElseThrow(() -> new ResourceNotFoundException("Organisateur", "codeOrganisateur", dto.getCodeOrganisateur()));
        event.setOrganisateur(org);

        Evenement saved = evenementRepository.save(event);
        log.info("Event created: id={}", saved.getIdEvenement());
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO update(Integer id, EvenementDTO dto) {
        log.debug("Updating event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (dto.getTitre() != null) event.setTitre(dto.getTitre());
        if (dto.getDescription() != null) event.setDescription(dto.getDescription());
        if (dto.getDateEvenement() != null) event.setDateEvenement(dto.getDateEvenement());
        if (dto.getHeureEvenement() != null) event.setHeureEvenement(dto.getHeureEvenement());
        if (dto.getImage() != null) event.setImage(dto.getImage());
        if (dto.getStatut() != null) {
            if (!VALID_STATUSES.contains(dto.getStatut())) {
                throw new BadRequestException("Invalid status. Valid values: " + VALID_STATUSES);
            }
            String current = event.getStatut();
            List<String> allowed = ALLOWED_TRANSITIONS.getOrDefault(current, List.of());
            if (!allowed.contains(dto.getStatut()) && !dto.getStatut().equals(current)) {
                throw new BadRequestException("Status transition not allowed: " + current + " → " + dto.getStatut());
            }
            event.setStatut(dto.getStatut());
        }
        if (dto.getCodeCategorie() != null) {
            Categorie cat = categorieRepository.findByCodeCategorie(dto.getCodeCategorie())
                    .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", dto.getCodeCategorie()));
            event.setCategorie(cat);
        }
        if (dto.getIdLieu() != null) {
            Lieu lieu = lieuRepository.findByIdLieu(dto.getIdLieu())
                    .orElseThrow(() -> new ResourceNotFoundException("Lieu", "idLieu", dto.getIdLieu()));
            event.setLieu(lieu);
        }
        Evenement saved = evenementRepository.save(event);
        log.info("Event updated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting event: {}", id);
        if (!evenementRepository.existsByIdEvenement(id)) {
            throw new ResourceNotFoundException("Evenement", "idEvenement", id);
        }
        evenementRepository.deleteById(id);
        log.info("Event deleted: id={}", id);
    }

    @Transactional
    public EvenementDTO validate(Integer id) {
        log.debug("Validating event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"planifie".equals(event.getStatut())) {
            throw new BadRequestException("Only planned events can be validated. Current status: " + event.getStatut());
        }
        event.setStatut("valide");
        Evenement saved = evenementRepository.save(event);
        log.info("Event validated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO suspend(Integer id) {
        log.debug("Suspending event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"valide".equals(event.getStatut()) && !"planifie".equals(event.getStatut()) && !"en_cours".equals(event.getStatut())) {
            throw new BadRequestException("Event cannot be suspended. Current status: " + event.getStatut());
        }
        event.setStatut("suspendu");
        Evenement saved = evenementRepository.save(event);
        log.info("Event suspended: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO resume(Integer id) {
        log.debug("Resuming event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if (!"suspendu".equals(event.getStatut())) {
            throw new BadRequestException("Only suspended events can be resumed. Current status: " + event.getStatut());
        }
        event.setStatut("valide");
        Evenement saved = evenementRepository.save(event);
        log.info("Event resumed: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public EvenementDTO cancel(Integer id, String motif) {
        log.debug("Cancelling event: {}", id);
        Evenement event = evenementRepository.findByIdEvenement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", id));
        if ("annule".equals(event.getStatut()) || "termine".equals(event.getStatut())) {
            throw new BadRequestException("Event cannot be cancelled. Current status: " + event.getStatut());
        }
        event.setStatut("annule");
        event.setMotifAnnulation(motif);
        Evenement saved = evenementRepository.save(event);
        log.info("Event cancelled: id={}", id);
        return toDTO(saved);
    }

    private EvenementDTO toDTO(Evenement event) {
        EvenementDTO dto = new EvenementDTO();
        dto.setIdEvenement(event.getIdEvenement());
        dto.setTitre(event.getTitre());
        dto.setDescription(event.getDescription());
        dto.setDateEvenement(event.getDateEvenement());
        dto.setHeureEvenement(event.getHeureEvenement());
        dto.setImage(event.getImage());
        dto.setStatut(event.getStatut());
        dto.setMotifAnnulation(event.getMotifAnnulation());
        dto.setCodeCategorie(event.getCategorie() != null ? event.getCategorie().getCodeCategorie() : null);
        dto.setCategorieNom(event.getCategorie() != null ? event.getCategorie().getNomCategorie() : null);
        dto.setIdLieu(event.getLieu() != null ? event.getLieu().getIdLieu() : null);
        dto.setLieuNom(event.getLieu() != null ? event.getLieu().getNomLieu() : null);
        dto.setCodeOrganisateur(event.getOrganisateur().getCodeUtilisateur());
        dto.setOrganisateurNom(event.getOrganisateur().getPrenoms() + " " + event.getOrganisateur().getNom());
        if (event.getIdEvenement() != null && event.getLieu() != null) {
            long total = placeRepository.countPlacesForEventLocation(event.getIdEvenement());
            long reserved = concernerRepository.findByEvenement_IdEvenement(event.getIdEvenement()).size();
            dto.setPlacesTotal(total);
            dto.setPlacesDisponibles(total - reserved);
        }
        return dto;
    }
}
