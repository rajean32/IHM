package com.ihm.repository;

import com.ihm.model.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, String> {

    Optional<Utilisateur> findByCodeUtilisateur(String codeUtilisateur);

    Optional<Utilisateur> findByEmail(String email);

    boolean existsByCodeUtilisateur(String codeUtilisateur);

    boolean existsByEmail(String email);
}
