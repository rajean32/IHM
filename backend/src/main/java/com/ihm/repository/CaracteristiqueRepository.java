package com.ihm.repository;

import com.ihm.model.Caracteristique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CaracteristiqueRepository extends JpaRepository<Caracteristique, Integer> {
    List<Caracteristique> findByCategorieCodeCategorieOrderByOrdreAffichageAsc(String codeCategorie);
    void deleteByCategorieCodeCategorie(String codeCategorie);
}
