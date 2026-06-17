package com.ihm.repository;

import com.ihm.model.EvenementPlaceConfiguration;
import org.springframework.data.jpa.repository.JpaRepository;
import java.math.BigDecimal;
import org.springframework.data.jpa.repository.Modifying;
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

    @Modifying
    @Query("DELETE FROM EvenementPlaceConfiguration e WHERE e.place.numeroPlace IN :placeIds")
    void deleteByPlaceNumeroPlaceIn(@Param("placeIds") List<String> placeIds);

    @Query("SELECT e FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND " +
           "LOWER(e.range) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(e.place.numeroPlace) LIKE LOWER(CONCAT('%', :q, '%')) OR "
           + "LOWER(e.typePlace) LIKE LOWER(CONCAT('%', :q, '%'))")
    List<EvenementPlaceConfiguration> searchByEventAndQuery(
            @Param("idEvent") Integer idEvent, @Param("q") String q);

    @Query("SELECT e FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND " +
           "e.typePlace = :typePlace")
    List<EvenementPlaceConfiguration> findByEventAndTypePlace(
            @Param("idEvent") Integer idEvent, @Param("typePlace") String typePlace);

    @Query("SELECT MIN(e.prix) FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND e.prix > 0")
    BigDecimal findMinPrixByEvenementId(@Param("idEvent") Integer idEvent);

    @Query("SELECT MAX(e.prix) FROM EvenementPlaceConfiguration e WHERE e.evenement.idEvenement = :idEvent AND e.prix > 0")
    BigDecimal findMaxPrixByEvenementId(@Param("idEvent") Integer idEvent);
}
