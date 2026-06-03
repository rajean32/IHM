package com.ihm.repository;

import com.ihm.model.CorrespondA;
import com.ihm.model.CorrespondAId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CorrespondARepository extends JpaRepository<CorrespondA, CorrespondAId> {

    List<CorrespondA> findByTicket_CodeTicket(String codeTicket);

    List<CorrespondA> findByReservation_IdReservation(Integer idReservation);
}
