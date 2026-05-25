package com.ihm.repository;

import com.ihm.schemat.Organisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrganisateurRepository extends JpaRepository<Organisateur, String> {

    Optional<Organisateur> findByCodeUtilisateur(String codeUtilisateur);

    boolean existsByCodeUtilisateur(String codeUtilisateur);
}
