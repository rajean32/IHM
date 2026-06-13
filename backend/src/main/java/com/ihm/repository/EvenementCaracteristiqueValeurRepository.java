package com.ihm.repository;

import com.ihm.model.EvenementCaracteristiqueValeur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EvenementCaracteristiqueValeurRepository extends JpaRepository<EvenementCaracteristiqueValeur, Integer> {
    List<EvenementCaracteristiqueValeur> findByEvenementIdEvenement(Integer idEvenement);
    void deleteByEvenementIdEvenement(Integer idEvenement);
}
