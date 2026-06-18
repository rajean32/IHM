package com.ihm.repository;

import com.ihm.model.Message;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByIdConversationOrderByDateEnvoiDesc(Long idConversation, Pageable pageable);

    List<Message> findByIdConversationOrderByDateEnvoiAsc(Long idConversation);

    long countByIdConversationAndDestinataireAndLuFalse(Long idConversation, String destinataire);

    @Modifying
    @Query("UPDATE Message m SET m.lu = true WHERE m.idConversation = :convId AND m.destinataire = :userId AND m.lu = false")
    void markAsRead(@Param("convId") Long convId, @Param("userId") String userId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.destinataire = :userId AND m.lu = false")
    long countUnreadByDestinataire(@Param("userId") String userId);
}
