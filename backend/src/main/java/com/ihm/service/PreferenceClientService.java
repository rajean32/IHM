package com.ihm.service;

import com.ihm.model.PreferenceClient;
import com.ihm.repository.PreferenceClientRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PreferenceClientService {

    private static final Logger log = LoggerFactory.getLogger(PreferenceClientService.class);

    private final PreferenceClientRepository repository;

    public PreferenceClientService(PreferenceClientRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<PreferenceClient> getPreferences(String codeClient) {
        return repository.findByCodeClient(codeClient);
    }

    @Transactional
    public PreferenceClient addPreference(String codeClient, String codeCategorie) {
        PreferenceClient pref = new PreferenceClient(codeClient, codeCategorie);
        PreferenceClient saved = repository.save(pref);
        log.info("Preference added: client={}, categorie={}", codeClient, codeCategorie);
        return saved;
    }

    @Transactional
    public void removePreference(String codeClient, String codeCategorie) {
        repository.deleteByCodeClientAndCodeCategorie(codeClient, codeCategorie);
        log.info("Preference removed: client={}, categorie={}", codeClient, codeCategorie);
    }
}
