package com.ihm.repository;

import com.ihm.model.Place;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlaceRepository extends JpaRepository<Place, String> {

    Optional<Place> findByNumeroPlace(String numeroPlace);

    List<Place> findBySalle_NumeroSalle(String numeroSalle);

    boolean existsByNumeroPlace(String numeroPlace);

    @Query("SELECT p FROM Place p WHERE p.salle IN (SELECT s FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent))")
    List<Place> findPlacesForEventLocation(@Param("idEvent") Integer idEvent);

    @Query("SELECT p FROM Place p WHERE p.salle.numeroSalle = :salle AND p.typePlace = :typePlace")
    List<Place> findBySalleAndTypePlace(@Param("salle") String salle, @Param("typePlace") String typePlace);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.salle IN (SELECT s FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent))")
    long countPlacesForEventLocation(@Param("idEvent") Integer idEvent);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.statut = 'RESERVEE' AND p.numeroPlace NOT IN (SELECT c.place.numeroPlace FROM Concerner c)")
    long countReservedWithoutConcerner();

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Place p WHERE p.numeroPlace IN :ids")
    List<Place> findByIdsWithLock(@Param("ids") List<String> ids);

    @Query("SELECT p FROM Place p WHERE p.statut = 'EN_ATTENTE' AND p.dateMiseEnAttente IS NOT NULL AND p.dateMiseEnAttente < :expiry")
    List<Place> findExpiredPending(@Param("expiry") LocalDateTime expiry);
}
