package com.ihm.repository;

import com.ihm.model.Abonnement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AbonnementRepository extends JpaRepository<Abonnement, Long> {

    List<Abonnement> findByCodeClient(String codeClient);

    List<Abonnement> findByCodeOrganisateur(String codeOrganisateur);

    Optional<Abonnement> findByCodeClientAndCodeOrganisateur(String codeClient, String codeOrganisateur);

    boolean existsByCodeClientAndCodeOrganisateur(String codeClient, String codeOrganisateur);

    void deleteByCodeClientAndCodeOrganisateur(String codeClient, String codeOrganisateur);
}
