package com.ihm.repository;

import com.ihm.schemat.Salle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalleRepository extends JpaRepository<Salle, String> {

    Optional<Salle> findByNumeroSalle(String numeroSalle);

    List<Salle> findByLieu_IdLieu(Integer idLieu);

    boolean existsByNumeroSalle(String numeroSalle);
}
