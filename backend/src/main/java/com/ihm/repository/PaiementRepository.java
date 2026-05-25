package com.ihm.repository;

import com.ihm.schemat.Paiement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaiementRepository extends JpaRepository<Paiement, Integer> {

    Optional<Paiement> findByIdPaiement(Integer idPaiement);

    Optional<Paiement> findByReservation_IdReservation(Integer idReservation);

    boolean existsByReservation_IdReservation(Integer idReservation);
}
