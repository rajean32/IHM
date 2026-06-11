package com.ihm.repository;

import com.ihm.model.SalleTypeEvenement;
import com.ihm.model.SalleTypeEvenement.SalleTypeEvenementId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SalleTypeEvenementRepository extends JpaRepository<SalleTypeEvenement, SalleTypeEvenementId> {
    List<SalleTypeEvenement> findByCategorieCodeCategorie(String codeCategorie);
    List<SalleTypeEvenement> findBySalleNumeroSalle(String numeroSalle);
    void deleteByCategorieCodeCategorie(String codeCategorie);
}
