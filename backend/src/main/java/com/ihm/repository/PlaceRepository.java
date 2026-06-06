package com.ihm.repository;

import com.ihm.model.Place;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PlaceRepository extends JpaRepository<Place, String> {

    Optional<Place> findByNumeroPlace(String numeroPlace);

    List<Place> findBySalle_NumeroSalle(String numeroSalle);

    boolean existsByNumeroPlace(String numeroPlace);

    @Query("SELECT p FROM Place p WHERE p.salle IN (SELECT s FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent))")
    List<Place> findPlacesForEventLocation(@Param("idEvent") Integer idEvent);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.salle IN (SELECT s FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent))")
    long countPlacesForEventLocation(@Param("idEvent") Integer idEvent);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Place p WHERE p.numeroPlace IN :ids")
    List<Place> findByIdsWithLock(@Param("ids") List<String> ids);
}
