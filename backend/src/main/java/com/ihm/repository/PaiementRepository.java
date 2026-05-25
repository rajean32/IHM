package com.ihm.repository;

import com.ihm.schemat.Paiement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaiementRepository extends JpaRepository<Paiement, Integer> {

    Optional<Paiement> findByIdPaiement(Integer idPaiement);

    Optional<Paiement> findByReservation_IdReservation(Integer idReservation);

    boolean existsByReservation_IdReservation(Integer idReservation);

    @Query("SELECT p FROM Paiement p WHERE p.reservation.client.codeUtilisateur = :codeClient")
    List<Paiement> findByClient(@Param("codeClient") String codeClient);

    @Query("SELECT SUM(p.montant) FROM Paiement p WHERE p.reservation.client.codeUtilisateur = :codeClient")
    BigDecimal sumByClient(@Param("codeClient") String codeClient);

    @Query("SELECT COALESCE(SUM(p.montant), 0) FROM Paiement p WHERE p.reservation.idReservation = :idReservation")
    BigDecimal sumByReservation(@Param("idReservation") Integer idReservation);

    @Query("SELECT SUM(p.montant) FROM Paiement p")
    BigDecimal sumTotal();

    @Query("SELECT p.reservation.idReservation, SUM(p.montant) FROM Paiement p GROUP BY p.reservation.idReservation ORDER BY SUM(p.montant) DESC")
    List<Object[]> topReservationsByRevenue(org.springframework.data.domain.Pageable pageable);

    @Query("SELECT COUNT(p) FROM Paiement p WHERE p.reservation.client.codeUtilisateur = :codeClient")
    long countByClient(@Param("codeClient") String codeClient);
}
