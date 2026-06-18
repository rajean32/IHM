package com.ihm.repository;

import com.ihm.model.PreferenceClient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PreferenceClientRepository extends JpaRepository<PreferenceClient, Long> {

    List<PreferenceClient> findByCodeClient(String codeClient);

    void deleteByCodeClientAndCodeCategorie(String codeClient, String codeCategorie);
}
