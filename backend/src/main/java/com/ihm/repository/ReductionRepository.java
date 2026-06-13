package com.ihm.repository;

import com.ihm.model.Reduction;
import com.ihm.model.enums.ModeReduction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReductionRepository extends JpaRepository<Reduction, Long> {

    Optional<Reduction> findByCode(String code);

    List<Reduction> findByEvenement_IdEvenement(Integer idEvenement);

    List<Reduction> findByModeAndActifTrue(ModeReduction mode);

    @Query("SELECT r FROM Reduction r WHERE r.actif = true AND " +
           "(r.dateDebut IS NULL OR r.dateDebut <= :now) AND " +
           "(r.dateFin IS NULL OR r.dateFin >= :now) AND " +
           "(r.utilisationMax IS NULL OR r.utilisationCount < r.utilisationMax)")
    List<Reduction> findActiveReductions(@Param("now") LocalDateTime now);

    @Query("SELECT r FROM Reduction r WHERE r.evenement.idEvenement = :idEvent AND r.actif = true")
    List<Reduction> findActiveByEvent(@Param("idEvent") Integer idEvent);

    boolean existsByCode(String code);
}