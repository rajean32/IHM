package com.ihm.repository;

import com.ihm.schemat.EvenementPlaceConfiguration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EvenementPlaceConfigurationRepository extends JpaRepository<EvenementPlaceConfiguration, Long> {

    List<EvenementPlaceConfiguration> findByEvenement_IdEvenement(Integer idEvenement);

    Optional<EvenementPlaceConfiguration> findByEvenement_IdEvenementAndPlace_NumeroPlace(
            Integer idEvenement, String numeroPlace);

    boolean existsByEvenement_IdEvenementAndPlace_NumeroPlace(
            Integer idEvenement, String numeroPlace);

    void deleteByEvenement_IdEvenement(Integer idEvenement);

    @Query("SELECT e FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND " +
           "LOWER(e.place.range) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(e.place.numeroPlace) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(e.typePlaceOverride) LIKE LOWER(CONCAT('%', :q, '%'))")
    List<EvenementPlaceConfiguration> searchByEventAndQuery(
            @Param("idEvent") Integer idEvent, @Param("q") String q);

    @Query("SELECT e FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND " +
           "e.typePlaceOverride = :typePlace")
    List<EvenementPlaceConfiguration> findByEventAndTypePlace(
            @Param("idEvent") Integer idEvent, @Param("typePlace") String typePlace);
}
