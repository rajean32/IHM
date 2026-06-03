package com.ihm.repository;

import com.ihm.model.Organisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrganisateurRepository extends JpaRepository<Organisateur, String> {

    Optional<Organisateur> findByCodeUtilisateur(String codeUtilisateur);

    boolean existsByCodeUtilisateur(String codeUtilisateur);

    @Query("SELECT COUNT(o) FROM Organisateur o")
    long countAllOrganisateurs();
}
