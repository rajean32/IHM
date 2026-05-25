package com.ihm.repository;

import com.ihm.schemat.Administrateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AdministrateurRepository extends JpaRepository<Administrateur, String> {

    Optional<Administrateur> findByCodeAdministrateur(String codeAdministrateur);

    boolean existsByCodeAdministrateur(String codeAdministrateur);
}
