package com.ihm.repository;

import com.ihm.model.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String> {

    Optional<Ticket> findByCodeTicket(String codeTicket);

    boolean existsByCodeTicket(String codeTicket);

    List<Ticket> findByConcerners_Evenement_IdEvenement(Integer idEvenement);

    List<Ticket> findByConcerners_Place_NumeroPlace(String numeroPlace);

    List<Ticket> findByCorrespondances_Reservation_Client_CodeUtilisateur(String codeClient);

    @Query("SELECT MIN(t.prix) FROM Ticket t JOIN t.concerners c WHERE c.evenement.idEvenement = :idEvent")
    BigDecimal findMinPriceByEvent(@Param("idEvent") Integer idEvent);

    @Query("SELECT MAX(t.prix) FROM Ticket t JOIN t.concerners c WHERE c.evenement.idEvenement = :idEvent")
    BigDecimal findMaxPriceByEvent(@Param("idEvent") Integer idEvent);

    @Query("SELECT COUNT(t) FROM Ticket t JOIN t.concerners c WHERE c.evenement.idEvenement = :idEvent")
    long countByEvent(@Param("idEvent") Integer idEvent);

    @Query("SELECT COUNT(t) FROM Ticket t WHERE t.codeTicket NOT IN (SELECT c.ticket.codeTicket FROM Concerner c)")
    long countOrphanTickets();
}
