package com.ihm.repository;

import com.ihm.model.PreferenceNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PreferenceNotificationRepository extends JpaRepository<PreferenceNotification, Long> {

    List<PreferenceNotification> findByCodeUtilisateur(String codeUtilisateur);

    List<PreferenceNotification> findByCodeUtilisateurAndActifTrue(String codeUtilisateur);
}
