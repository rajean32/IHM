package com.ihm.repository;

import com.ihm.schemat.Salle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalleRepository extends JpaRepository<Salle, String> {

    Optional<Salle> findByNumeroSalle(String numeroSalle);

    List<Salle> findByLieu_IdLieu(Integer idLieu);

    boolean existsByNumeroSalle(String numeroSalle);

    @Query("SELECT COUNT(s) FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent)")
    long countSallesForEvent(@Param("idEvent") Integer idEvent);
}
