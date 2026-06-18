package com.ihm.repository;

import com.ihm.model.Avis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AvisRepository extends JpaRepository<Avis, Long> {

    List<Avis> findByIdEvenementOrderByDateCreationDesc(Integer idEvenement);

    Optional<Avis> findByIdEvenementAndCodeClient(Integer idEvenement, String codeClient);

    boolean existsByIdEvenementAndCodeClient(Integer idEvenement, String codeClient);

    @Query("SELECT AVG(a.note) FROM Avis a WHERE a.idEvenement = :idEvenement")
    Double avgNoteByEvenement(@Param("idEvenement") Integer idEvenement);

    long countByIdEvenement(Integer idEvenement);
}
