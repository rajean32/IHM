package com.ihm.repository;

import com.ihm.schemat.Place;
import org.springframework.data.jpa.repository.JpaRepository;
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

    @Query("SELECT p FROM Place p WHERE p.salle.numeroSalle = :salle AND p.typePlace = :typePlace")
    List<Place> findBySalleAndTypePlace(@Param("salle") String salle, @Param("typePlace") String typePlace);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.salle IN (SELECT s FROM Salle s WHERE s.lieu IN (SELECT e.lieu FROM Evenement e WHERE e.idEvenement = :idEvent))")
    long countPlacesForEventLocation(@Param("idEvent") Integer idEvent);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.statut = 'RESERVEE' AND p.numeroPlace NOT IN (SELECT c.place.numeroPlace FROM Concerner c)")
    long countReservedWithoutConcerner();
}
