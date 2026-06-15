package com.ihm.repository;

import com.ihm.model.InAppNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface InAppNotificationRepository extends JpaRepository<InAppNotification, Long> {

    List<InAppNotification> findByUserIdOrderByCreatedAtDesc(String userId);

    List<InAppNotification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(String userId);

    long countByUserIdAndIsReadFalse(String userId);

    @Query("SELECT n FROM InAppNotification n WHERE n.userId = :userId " +
           "AND (:type IS NULL OR n.type = :type) " +
           "AND (:isRead IS NULL OR n.isRead = :isRead) " +
           "AND (:dateFrom IS NULL OR n.createdAt >= :dateFrom) " +
           "AND (:dateTo IS NULL OR n.createdAt <= :dateTo) " +
           "ORDER BY n.createdAt DESC")
    List<InAppNotification> findFiltered(
            @Param("userId") String userId,
            @Param("type") String type,
            @Param("isRead") Boolean isRead,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo);
}
