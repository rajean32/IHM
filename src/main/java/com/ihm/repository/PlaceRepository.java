package com.ihm.repository;

import com.ihm.schemat.Place;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PlaceRepository extends JpaRepository<Place, String> {

    Optional<Place> findByNumeroPlace(String numeroPlace);

    List<Place> findBySalle_NumeroSalle(String numeroSalle);

    boolean existsByNumeroPlace(String numeroPlace);
}
