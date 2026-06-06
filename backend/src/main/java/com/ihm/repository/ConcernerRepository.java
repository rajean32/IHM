package com.ihm.repository;

import com.ihm.model.Concerner;
import com.ihm.model.ConcernerId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConcernerRepository extends JpaRepository<Concerner, ConcernerId> {

    List<Concerner> findByEvenement_IdEvenement(Integer idEvenement);

    List<Concerner> findByTicket_CodeTicket(String codeTicket);

    List<Concerner> findByPlace_NumeroPlace(String numeroPlace);

    boolean existsByEvenement_IdEvenementAndPlace_NumeroPlace(Integer idEvenement, String numeroPlace);

    @Modifying
    @Query("DELETE FROM Concerner c WHERE c.place.numeroPlace IN :placeIds")
    void deleteByPlaceNumeroPlaceIn(@Param("placeIds") List<String> placeIds);
}
