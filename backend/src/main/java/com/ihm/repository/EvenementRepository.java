package com.ihm.repository;

import com.ihm.schemat.Evenement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EvenementRepository extends JpaRepository<Evenement, Integer> {

    Optional<Evenement> findByIdEvenement(Integer idEvenement);

    List<Evenement> findByOrganisateur_CodeUtilisateur(String codeOrganisateur);

    List<Evenement> findByCategorie_CodeCategorie(String codeCategorie);

    List<Evenement> findByDateEvenementBetween(LocalDate start, LocalDate end);

    List<Evenement> findByLieu_IdLieu(Integer idLieu);

    List<Evenement> findByStatut(String statut);

    boolean existsByIdEvenement(Integer idEvenement);
}
