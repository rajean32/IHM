package com.ihm.config;

import com.ihm.repository.AdministrateurRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.model.Administrateur;
import com.ihm.model.Utilisateur;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private static final String DEFAULT_ADMIN_CODE = "ADMIN_DEFAULT";
    private static final String DEFAULT_ADMIN_EMAIL = "admin@admin.mg";
    private static final String DEFAULT_ADMIN_PASSWORD = "admin123";

    private final AdministrateurRepository administrateurRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(AdministrateurRepository administrateurRepository,
                           UtilisateurRepository utilisateurRepository,
                           PasswordEncoder passwordEncoder) {
        this.administrateurRepository = administrateurRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (administrateurRepository.existsByCodeAdministrateur(DEFAULT_ADMIN_CODE)) {
            log.info("Default admin account already exists, skipping creation");
            return;
        }

        log.info("Creating default admin account...");

        Administrateur admin = new Administrateur(DEFAULT_ADMIN_CODE, passwordEncoder.encode(DEFAULT_ADMIN_PASSWORD));
        admin = administrateurRepository.save(admin);

        Utilisateur user = new Utilisateur();
        user.setCodeUtilisateur(DEFAULT_ADMIN_CODE);
        user.setNom("Admin");
        user.setPrenoms("System");
        user.setSexe("M");
        user.setDateDeNaissance(LocalDate.of(2000, 1, 1));
        user.setEmail(DEFAULT_ADMIN_EMAIL);
        user.setTel("0000000000");
        user.setMotDePasse(passwordEncoder.encode(DEFAULT_ADMIN_PASSWORD));
        user.setPremiereConnexion(true);
        user.setAdministrateur(admin);
        utilisateurRepository.save(user);

        log.info("Default admin account created: email={}, password={}, firstLogin=true", DEFAULT_ADMIN_EMAIL, DEFAULT_ADMIN_PASSWORD);
    }
}
