package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.dto.LoginRequest;
import com.ihm.model.dto.LoginResponse;
import com.ihm.model.dto.RegisterRequest;
import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schemat.Administrateur;
import com.ihm.schemat.Client;
import com.ihm.schemat.Organisateur;
import com.ihm.schemat.Utilisateur;
import com.ihm.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UtilisateurRepository utilisateurRepository;
    private final OrganisateurRepository organisateurRepository;
    private final ClientRepository clientRepository;
    private final AdministrateurRepository administrateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(UtilisateurRepository utilisateurRepository,
                       OrganisateurRepository organisateurRepository,
                       ClientRepository clientRepository,
                       AdministrateurRepository administrateurRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil) {
        this.utilisateurRepository = utilisateurRepository;
        this.organisateurRepository = organisateurRepository;
        this.clientRepository = clientRepository;
        this.administrateurRepository = administrateurRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public LoginResponse login(LoginRequest request) {
        log.debug("Login attempt for email: {}", request.getEmail());

        Utilisateur user = utilisateurRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur", "email", request.getEmail()));

        if (!passwordEncoder.matches(request.getMotDePasse(), user.getMotDePasse())) {
            throw new BadRequestException("Invalid email or password");
        }

        String role = determineRole(user);
        String token = jwtUtil.generateToken(user.getCodeUtilisateur(), role);

        log.info("User logged in: {}", user.getCodeUtilisateur());
        return new LoginResponse(token, user.getCodeUtilisateur(), user.getEmail(), role);
    }

    @Transactional
    public LoginResponse register(RegisterRequest request) {
        log.debug("Register attempt for email: {}", request.getEmail());

        if (utilisateurRepository.existsByCodeUtilisateur(request.getCodeUtilisateur())) {
            throw new DuplicateResourceException("Utilisateur", "codeUtilisateur", request.getCodeUtilisateur());
        }
        if (utilisateurRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Utilisateur", "email", request.getEmail());
        }

        String type = (request.getType() != null) ? request.getType().toLowerCase() : "client";
        Utilisateur user;

        switch (type) {
            case "organisateur":
                Organisateur org = new Organisateur();
                populateFields(org, request);
                user = organisateurRepository.save(org);
                break;
            case "client":
            default:
                Client client = new Client();
                populateFields(client, request);
                user = clientRepository.save(client);
                break;
        }

        String role = type.equals("organisateur") ? "ORGANISATEUR" : "CLIENT";
        String token = jwtUtil.generateToken(user.getCodeUtilisateur(), role);

        log.info("User registered: {} as {}", user.getCodeUtilisateur(), role);
        return new LoginResponse(token, user.getCodeUtilisateur(), user.getEmail(), role);
    }

    private void populateFields(Utilisateur user, RegisterRequest request) {
        user.setCodeUtilisateur(request.getCodeUtilisateur());
        user.setNom(request.getNom());
        user.setPrenoms(request.getPrenoms());
        user.setSexe(request.getSexe());
        user.setDateDeNaissance(request.getDateDeNaissance());
        user.setEmail(request.getEmail());
        user.setTel(request.getTel());
        user.setMotDePasse(passwordEncoder.encode(request.getMotDePasse()));
    }

    private String determineRole(Utilisateur user) {
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
