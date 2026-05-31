package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.UserCreateRequest;
import com.ihm.model.dto.UserDetailDTO;
import com.ihm.model.dto.UserRoleUpdateRequest;
import com.ihm.repository.*;
import com.ihm.schemat.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AdminUserService {

    private static final Logger log = LoggerFactory.getLogger(AdminUserService.class);

    private final UtilisateurRepository utilisateurRepository;
    private final ClientRepository clientRepository;
    private final OrganisateurRepository organisateurRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final ActionLogService actionLogService;

    public AdminUserService(UtilisateurRepository utilisateurRepository,
                            ClientRepository clientRepository,
                            OrganisateurRepository organisateurRepository,
                            AdministrateurRepository administrateurRepository,
                            PasswordEncoder passwordEncoder,
                            ActionLogService actionLogService) {
        this.utilisateurRepository = utilisateurRepository;
        this.clientRepository = clientRepository;
        this.organisateurRepository = organisateurRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.actionLogService = actionLogService;
    }

    public List<UserDetailDTO> getAllUsers() {
        return utilisateurRepository.findAll().stream()
                .map(this::toDetailDTO)
                .collect(Collectors.toList());
    }

    public UserDetailDTO getUserById(String code) {
        Utilisateur user = utilisateurRepository.findByCodeUtilisateur(code)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "codeUtilisateur", code));
        return toDetailDTO(user);
    }

    @Transactional
    public UserDetailDTO createUser(UserCreateRequest request, String adminCode) {
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

    @Transactional
    public UserDetailDTO updateUser(String code, UserCreateRequest request, String adminCode) {
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
            updateUserRole(code, new UserRoleUpdateRequest(request.getRole()), adminCode);
        }

        actionLogService.log(adminCode, "UPDATE_USER", "Utilisateur", code, "Updated user info");

        return toDetailDTO(saved);
    }

    @Transactional
    public UserDetailDTO updateUserRole(String code, UserRoleUpdateRequest request, String adminCode) {
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

    private String generateUserCode(String role) {
        String prefix = switch (role.toUpperCase()) {
            case "ORGANISATEUR" -> "ORG";
            default -> "CLT";
        };
        return prefix + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private void populateUser(Utilisateur user, UserCreateRequest request) {
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

    private UserDetailDTO toDetailDTO(Utilisateur user) {
        UserDetailDTO dto = new UserDetailDTO();
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
}
