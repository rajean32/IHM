package com.ihm.repository;

import com.ihm.schemat.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String> {

    Optional<Ticket> findByCodeTicket(String codeTicket);

    boolean existsByCodeTicket(String codeTicket);
}
