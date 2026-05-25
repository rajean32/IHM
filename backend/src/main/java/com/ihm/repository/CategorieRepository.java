package com.ihm.repository;

import com.ihm.schemat.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategorieRepository extends JpaRepository<Categorie, String> {

    Optional<Categorie> findByCodeCategorie(String codeCategorie);

    boolean existsByCodeCategorie(String codeCategorie);
}
