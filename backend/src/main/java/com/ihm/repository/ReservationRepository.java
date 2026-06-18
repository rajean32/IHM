package com.ihm.repository;

import com.ihm.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Integer> {

    Optional<Reservation> findByIdReservation(Integer idReservation);

    List<Reservation> findByClient_CodeUtilisateur(String codeClient);

    @Query("SELECT r FROM Reservation r JOIN FETCH r.correspondances ca JOIN FETCH ca.ticket t WHERE r.client.codeUtilisateur = :codeClient ORDER BY r.dateReservation DESC")
    List<Reservation> findByClientWithTickets(@Param("codeClient") String codeClient);

    boolean existsByIdReservation(Integer idReservation);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.client.codeUtilisateur = :codeClient")
    long countByClient(@Param("codeClient") String codeClient);

    @Query("SELECT r FROM Reservation r ORDER BY r.dateReservation DESC")
    List<Reservation> findRecentReservations(org.springframework.data.domain.Pageable pageable);

    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.idReservation NOT IN (SELECT p.reservation.idReservation FROM Paiement p)")
    long countWithoutPayment();

    @Query("SELECT DISTINCT r FROM Reservation r JOIN r.correspondances ca JOIN ca.ticket t JOIN t.concerners c WHERE c.evenement.idEvenement = :eventId ORDER BY r.dateReservation DESC")
    List<Reservation> findByEvenementId(@Param("eventId") Integer eventId);

    @Query("SELECT r FROM Reservation r JOIN FETCH r.correspondances ca JOIN FETCH ca.ticket t WHERE r.idReservation = :id")
    Optional<Reservation> findByIdWithCorrespondances(@Param("id") Integer id);

    @Query("SELECT r FROM Reservation r WHERE r.idReservation NOT IN (SELECT p.reservation.idReservation FROM Paiement p) AND r.dateReservation < :threshold")
    List<Reservation> findUnpaidOlderThan(@Param("threshold") LocalDateTime threshold);
}
