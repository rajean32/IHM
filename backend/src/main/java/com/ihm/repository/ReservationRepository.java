package com.ihm.repository;

import com.ihm.schemat.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Integer> {

    Optional<Reservation> findByIdReservation(Integer idReservation);

    List<Reservation> findByClient_CodeUtilisateur(String codeClient);

    boolean existsByIdReservation(Integer idReservation);
}
