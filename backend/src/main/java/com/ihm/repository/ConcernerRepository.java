package com.ihm.repository;

import com.ihm.schemat.Concerner;
import com.ihm.schemat.ConcernerId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConcernerRepository extends JpaRepository<Concerner, ConcernerId> {

    List<Concerner> findByEvenement_IdEvenement(Integer idEvenement);

    List<Concerner> findByTicket_CodeTicket(String codeTicket);

    List<Concerner> findByPlace_NumeroPlace(String numeroPlace);

    boolean existsByEvenement_IdEvenementAndPlace_NumeroPlace(Integer idEvenement, String numeroPlace);
}
