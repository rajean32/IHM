package com.ihm.service;

import com.ihm.model.PreferenceNotification;
import com.ihm.repository.PreferenceNotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PreferenceNotificationService {

    private static final Logger log = LoggerFactory.getLogger(PreferenceNotificationService.class);

    private final PreferenceNotificationRepository repository;

    public PreferenceNotificationService(PreferenceNotificationRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<PreferenceNotification> getPreferences(String codeUtilisateur) {
        return repository.findByCodeUtilisateur(codeUtilisateur);
    }

    @Transactional
    public PreferenceNotification setPreference(String codeUtilisateur, String typeNotification, String canal, boolean actif) {
        List<PreferenceNotification> existing = repository.findByCodeUtilisateur(codeUtilisateur);
        PreferenceNotification pref = existing.stream()
                .filter(p -> p.getTypeNotification().equals(typeNotification) && p.getCanal().equals(canal))
                .findFirst()
                .orElseGet(() -> new PreferenceNotification(codeUtilisateur, typeNotification, canal));
        pref.setActif(actif);
        repository.save(pref);
        log.debug("Preference {} / {} for {} set to {}", typeNotification, canal, codeUtilisateur, actif);
        return pref;
    }
}
