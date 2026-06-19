package com.ihm.repository;

import com.ihm.model.Ville;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VilleRepository extends JpaRepository<Ville, String> {
    List<Ville> findByActifTrueOrderByNomAsc();
    List<Ville> findAllByOrderByNomAsc();
    List<Ville> findByNomContainingIgnoreCase(String nom);
    Optional<Ville> findByNomIgnoreCase(String nom);
    boolean existsByNomIgnoreCase(String nom);
}
