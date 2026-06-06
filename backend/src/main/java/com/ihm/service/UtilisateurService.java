package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.UtilisateurDTO;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.ConcernerRepository;
import com.ihm.repository.CorrespondARepository;
import com.ihm.repository.EvenementPlaceConfigurationRepository;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.PaiementRepository;
import com.ihm.repository.PlaceRepository;
import com.ihm.repository.ReservationRepository;
import com.ihm.repository.TicketRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Administrateur;
import com.ihm.model.Client;
import com.ihm.model.Organisateur;
import com.ihm.model.Utilisateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UtilisateurService {

    private static final Logger log = LoggerFactory.getLogger(UtilisateurService.class);

    private final UtilisateurRepository utilisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final ClientRepository clientRepository;
    private final OrganisateurRepository organisateurRepository;
    private final EvenementRepository evenementRepository;
    private final PlaceRepository placeRepository;
    private final ConcernerRepository concernerRepository;
    private final CorrespondARepository correspondARepository;
    private final TicketRepository ticketRepository;
    private final ReservationRepository reservationRepository;
    private final PaiementRepository paiementRepository;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final ActionLogService actionLogService;
    private final PasswordEncoder passwordEncoder;

    public UtilisateurService(UtilisateurRepository utilisateurRepository,
                              AdministrateurRepository administrateurRepository,
                              ClientRepository clientRepository,
                              OrganisateurRepository organisateurRepository,
                              EvenementRepository evenementRepository,
                              PlaceRepository placeRepository,
                              ConcernerRepository concernerRepository,
                              CorrespondARepository correspondARepository,
                              TicketRepository ticketRepository,
                              ReservationRepository reservationRepository,
                              PaiementRepository paiementRepository,
                              EvenementPlaceConfigurationRepository configRepository,
                              ActionLogService actionLogService,
                              PasswordEncoder passwordEncoder) {
        this.utilisateurRepository = utilisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.clientRepository = clientRepository;
        this.organisateurRepository = organisateurRepository;
        this.evenementRepository = evenementRepository;
        this.placeRepository = placeRepository;
        this.concernerRepository = concernerRepository;
        this.correspondARepository = correspondARepository;
        this.ticketRepository = ticketRepository;
        this.reservationRepository = reservationRepository;
        this.paiementRepository = paiementRepository;
        this.configRepository = configRepository;
        this.actionLogService = actionLogService;
        this.passwordEncoder = passwordEncoder;
    }

    // ========== UtilisateurService methods ==========

    // recuperation de tous les utilisateurs
    public List<UtilisateurDTO> getAll() {
        log.debug("Fetching all users");
        return utilisateurRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un utilisateur
    public UtilisateurDTO getById(String code) {
        log.debug("Fetching user by code: {}", code);
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));
        return toDTO(user);
    }

    // creation d'un utilisateur
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

    // mise a jour d'un utilisateur
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

    // suppression d'un utilisateur
    @Transactional
    public void delete(String code) {
        log.debug("Deleting user: {}", code);
        if (!utilisateurRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code);
        }
        utilisateurRepository.deleteById(code);
        log.info("User deleted: {}", code);
    }

    // ========== AdministrateurService methods ==========

    // recuperation de tous les administrateurs
    public List<UtilisateurDTO.AdministrateurDTO> getAllAdministrateurs() {
        log.debug("Fetching all administrators");
        return administrateurRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un administrateur
    public UtilisateurDTO.AdministrateurDTO getAdministrateurById(String code) {
        log.debug("Fetching administrator by code: {}", code);
        Administrateur admin = administrateurRepository.findByCodeAdministrateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Administrateur", "codeAdministrateur", code));
        return toDTO(admin);
    }

    // creation d'un administrateur
    @Transactional
    public UtilisateurDTO.AdministrateurDTO createAdministrateur(UtilisateurDTO.AdministrateurDTO dto) {
        log.debug("Creating administrator: {}", dto.getCodeAdministrateur());
        if (administrateurRepository.existsByCodeAdministrateur(dto.getCodeAdministrateur())) {
            throw new DuplicateResourceException("Administrateur", "codeAdministrateur", dto.getCodeAdministrateur());
        }
        Administrateur admin = new Administrateur(dto.getCodeAdministrateur(), passwordEncoder.encode(dto.getMotdepasseAdministrateur()));
        Administrateur saved = administrateurRepository.save(admin);
        log.info("Administrator created: {}", saved.getCodeAdministrateur());
        return toDTO(saved);
    }

    // mise a jour d'un administrateur
    @Transactional
    public UtilisateurDTO.AdministrateurDTO updateAdministrateur(String code, UtilisateurDTO.AdministrateurDTO dto) {
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

    // suppression d'un administrateur
    @Transactional
    public void deleteAdministrateur(String code) {
        log.debug("Deleting administrator: {}", code);
        if (!administrateurRepository.existsByCodeAdministrateur(code)) {
            throw new ResourceNotFoundException("Administrateur", "codeAdministrateur", code);
        }
        administrateurRepository.deleteById(code);
        log.info("Administrator deleted: {}", code);
    }

    // ========== AdminUserService methods ==========

    // recuperation de tous les utilisateurs (detail)
    public List<UtilisateurDTO.UserDetail> getAllUsers() {
        return utilisateurRepository.findAll().stream()
                .map(this::toDetailDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'un utilisateur (detail)
    public UtilisateurDTO.UserDetail getUserById(String code) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));
        return toDetailDTO(user);
    }

    // creation d'un utilisateur par admin
    @Transactional
    public UtilisateurDTO.UserDetail createUser(UtilisateurDTO.UserCreateRequest request, String adminCode) {
        if (utilisateurRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Utilisateur", "email", request.getEmail());
        }

        String code = request.getCodeUtilisateur();
        if (code == null || code.isBlank()) {
            code = generateUserCode(request.getRole());
        } else if (utilisateurRepository.existsByCodeUtilisateur(code)) {
            throw new DuplicateResourceException("Utilisateur", "codeUtilisateur", code);
        }
        request.setCodeUtilisateur(code);

        String role = request.getRole().toUpperCase();
        Utilisateur user;

        switch (role) {
            case "CLIENT":
                Client client = new Client();
                populateUser(client, request);
                user = clientRepository.save(client);
                break;
            case "ORGANISATEUR":
                Organisateur org = new Organisateur();
                populateUser(org, request);
                user = organisateurRepository.save(org);
                break;
            default:
                Client defaultClient = new Client();
                populateUser(defaultClient, request);
                user = clientRepository.save(defaultClient);
        }

        actionLogService.log(adminCode, "CREATE_USER", "Utilisateur", request.getCodeUtilisateur(),
                "Created user with role: " + role);

        log.info("Admin {} created user {} with role {}", adminCode, request.getCodeUtilisateur(), role);
        return toDetailDTO(user);
    }

    // mise a jour d'un utilisateur par admin
    @Transactional
    public UtilisateurDTO.UserDetail updateUser(String code, UtilisateurDTO.UserUpdateRequest request, String adminCode) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));

        if (request.getNom() != null) user.setNom(request.getNom());
        if (request.getPrenoms() != null) user.setPrenoms(request.getPrenoms());
        if (request.getSexe() != null) user.setSexe(request.getSexe());
        if (request.getDateDeNaissance() != null) user.setDateDeNaissance(request.getDateDeNaissance());
        if (request.getTel() != null) user.setTel(request.getTel());
        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
            if (utilisateurRepository.existsByEmail(request.getEmail())) {
                throw new DuplicateResourceException("Utilisateur", "email", request.getEmail());
            }
            user.setEmail(request.getEmail());
        }
        if (request.getMotDePasse() != null && !request.getMotDePasse().isBlank()) {
            user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
        }

        Utilisateur saved = utilisateurRepository.save(user);

        if (request.getRole() != null) {
            updateUserRole(code, new UtilisateurDTO.UserRoleUpdateRequest(request.getRole()), adminCode);
        }

        actionLogService.log(adminCode, "UPDATE_USER", "Utilisateur", code, "Updated user info");

        return toDetailDTO(saved);
    }

    // changement de role d'un utilisateur
    @Transactional
    public UtilisateurDTO.UserDetail updateUserRole(String code, UtilisateurDTO.UserRoleUpdateRequest request, String adminCode) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));

        String newRole = request.getRole().toUpperCase();
        String currentRole = determineRole(user);

        if (currentRole.equals(newRole)) {
            return toDetailDTO(user);
        }

        switch (currentRole) {
            case "CLIENT":
                clientRepository.deleteById(code);
                break;
            case "ORGANISATEUR":
                organisateurRepository.deleteById(code);
                break;
        }

        switch (newRole) {
            case "CLIENT":
                Client client = new Client();
                copyFields(client, user);
                clientRepository.save(client);
                break;
            case "ORGANISATEUR":
                Organisateur org = new Organisateur();
                copyFields(org, user);
                organisateurRepository.save(org);
                break;
            default:
                Client defaultClient = new Client();
                copyFields(defaultClient, user);
                clientRepository.save(defaultClient);
        }

        actionLogService.log(adminCode, "CHANGE_ROLE", "Utilisateur", code,
                "Changed role from " + currentRole + " to " + newRole);

        log.info("Admin {} changed role of {} from {} to {}", adminCode, code, currentRole, newRole);
        return toDetailDTO(utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code)));
    }

    // activation/desactivation d'un utilisateur
    @Transactional
    public void toggleUserActive(String code, String adminCode) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));

        boolean was = user.isPremiereConnexion();
        user.setPremiereConnexion(!was);
        utilisateurRepository.save(user);

        actionLogService.log(adminCode, was ? "DEACTIVATE_USER" : "ACTIVATE_USER",
                "Utilisateur", code, "Toggled active to " + !was);
        log.info("Admin {} toggled active status of {} to {}", adminCode, code, !was);
    }

    // reinitialisation du mot de passe
    @Transactional
    public void resetPassword(String code, String newPassword, String adminCode) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));

        user.setMotDePasse(passwordEncoder.encode(newPassword));
        user.setPremiereConnexion(true);
        utilisateurRepository.save(user);

        actionLogService.log(adminCode, "RESET_PASSWORD", "Utilisateur", code, "Password reset by admin");
        log.info("Admin {} reset password for {}", adminCode, code);
    }

    // suppression d'un utilisateur par admin
    @Transactional
    public void deleteUser(String code, String adminCode) {
        if (!utilisateurRepository.existsByCodeUtilisateur(code)) {
            throw new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code);
        }
        String role = determineRole(utilisateurRepository.findByCodeUtilisateur(code).orElse(null));
        switch (role) {
            case "CLIENT": clientRepository.deleteById(code); break;
            case "ORGANISATEUR": organisateurRepository.deleteById(code); break;
        }
        utilisateurRepository.deleteById(code);

        actionLogService.log(adminCode, "DELETE_USER", "Utilisateur", code, "User deleted");
        log.info("Admin {} deleted user {}", adminCode, code);
    }

    // ========== DataConsistencyService methods ==========

    // generation du rapport de coherence
    public UtilisateurDTO.ConsistencyReport generateReport() {
        List<String> issues = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        long pastActiveEvents = evenementRepository.countByDateEvenementBeforeAndStatutNot(
                LocalDate.now(), "termine");
        if (pastActiveEvents > 0) {
            issues.add(pastActiveEvents + " evenement(s) passe(s) encore actif (non termines)");
        }

        long orphanTickets = ticketRepository.countOrphanTickets();
        if (orphanTickets > 0) {
            issues.add(orphanTickets + " ticket(s) sans reservation associee (orphelins)");
        }

        long reservationsWithoutPayment = reservationRepository.countWithoutPayment();
        if (reservationsWithoutPayment > 0) {
            warnings.add(reservationsWithoutPayment + " reservation(s) sans paiement associe");
        }

        long eventsWithoutSalles = evenementRepository.countEventsWithoutSallePlaces();
        if (eventsWithoutSalles > 0) {
            issues.add(eventsWithoutSalles + " evenement(s) sans aucune place configuree dans leur salle");
        }

        return new UtilisateurDTO.ConsistencyReport(issues, warnings);
    }

    // journalisation du rapport de coherence
    public void logReport() {
        UtilisateurDTO.ConsistencyReport report = generateReport();
        if (!report.getIssues().isEmpty()) {
            log.warn("=== INCONSISTANCES DETECTEES ===");
            report.getIssues().forEach(i -> log.warn("  ISSUE: {}", i));
        }
        if (!report.getWarnings().isEmpty()) {
            log.warn("=== AVERTISSEMENTS ===");
            report.getWarnings().forEach(w -> log.warn("  WARN: {}", w));
        }
        if (report.getIssues().isEmpty() && report.getWarnings().isEmpty()) {
            log.info("Data consistency check passed - no issues found.");
        }
    }

    // ========== Private helpers ==========

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

    private UtilisateurDTO.AdministrateurDTO toDTO(Administrateur admin) {
        UtilisateurDTO.AdministrateurDTO dto = new UtilisateurDTO.AdministrateurDTO();
        dto.setCodeAdministrateur(admin.getCodeAdministrateur());
        dto.setMotdepasseAdministrateur(admin.getMotdepasseAdministrateur());
        return dto;
    }

    private UtilisateurDTO.UserDetail toDetailDTO(Utilisateur user) {
        UtilisateurDTO.UserDetail dto = new UtilisateurDTO.UserDetail();
        dto.setCodeUtilisateur(user.getCodeUtilisateur());
        dto.setNom(user.getNom());
        dto.setPrenoms(user.getPrenoms());
        dto.setSexe(user.getSexe());
        dto.setDateDeNaissance(user.getDateDeNaissance());
        dto.setEmail(user.getEmail());
        dto.setTel(user.getTel());
        dto.setPremiereConnexion(user.isPremiereConnexion());
        dto.setActif(!user.isPremiereConnexion());
        dto.setRole(determineRole(user));
        if (user.getAdministrateur() != null) {
            dto.setCodeAdministrateur(user.getAdministrateur().getCodeAdministrateur());
        }
        return dto;
    }

    private String generateUserCode(String role) {
        String prefix = switch (role.toUpperCase()) {
            case "ORGANISATEUR" -> "ORG";
            default -> "CLT";
        };
        return prefix + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private void populateUser(Utilisateur user, UtilisateurDTO.UserCreateRequest request) {
        user.setCodeUtilisateur(request.getCodeUtilisateur());
        user.setNom(request.getNom());
        user.setPrenoms(request.getPrenoms());
        user.setSexe(request.getSexe());
        user.setDateDeNaissance(request.getDateDeNaissance());
        user.setEmail(request.getEmail());
        user.setTel(request.getTel());
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
        user.setPremiereConnexion(true);
    }

    private void copyFields(Utilisateur target, Utilisateur source) {
        target.setCodeUtilisateur(source.getCodeUtilisateur());
        target.setNom(source.getNom());
        target.setPrenoms(source.getPrenoms());
        target.setSexe(source.getSexe());
        target.setDateDeNaissance(source.getDateDeNaissance());
        target.setEmail(source.getEmail());
        target.setTel(source.getTel());
        target.setMotDePasse(source.getMotDePasse());
        target.setPremiereConnexion(source.isPremiereConnexion());
    }

    private String determineRole(Utilisateur user) {
        if (user == null) return "UTILISATEUR";
        if (administrateurRepository.findByCodeAdministrateur(user.getCodeUtilisateur()).isPresent()) {
            return "ADMINISTRATEUR";
        }
        if (organisateurRepository.findByCodeUtilisateur(user.getCodeUtilisateur()).isPresent()) {
            return "ORGANISATEUR";
        }
        if (clientRepository.findByCodeUtilisateur(user.getCodeUtilisateur()).isPresent()) {
            return "CLIENT";
        }
        return "UTILISATEUR";
    }
}
