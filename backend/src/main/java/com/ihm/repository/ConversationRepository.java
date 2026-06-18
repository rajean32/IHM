package com.ihm.repository;

import com.ihm.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    @Query("SELECT c FROM Conversation c WHERE c.participant1 = :userId OR c.participant2 = :userId ORDER BY c.lastMessageAt DESC")
    List<Conversation> findByParticipant(@Param("userId") String userId);

    @Query("SELECT c FROM Conversation c WHERE (c.participant1 = :p1 AND c.participant2 = :p2) OR (c.participant1 = :p2 AND c.participant2 = :p1)")
    Optional<Conversation> findByParticipants(@Param("p1") String p1, @Param("p2") String p2);

    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Conversation c WHERE (c.participant1 = :p1 AND c.participant2 = :p2) OR (c.participant1 = :p2 AND c.participant2 = :p1)")
    boolean existsByParticipants(@Param("p1") String p1, @Param("p2") String p2);
}
