package com.ihm.repository;

import com.ihm.model.SeanceCinema;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface SeanceCinemaRepository extends JpaRepository<SeanceCinema, Long> {

    List<SeanceCinema> findByFilm_IdFilm(Long idFilm);

    List<SeanceCinema> findByEvenement_IdEvenement(Integer idEvenement);

    List<SeanceCinema> findByDateSeance(LocalDate dateSeance);

    List<SeanceCinema> findByDateSeanceAfter(LocalDate date);

    @Query("SELECT s FROM SeanceCinema s WHERE s.film.titre LIKE %:query% OR s.film.realisateur LIKE %:query%")
    List<SeanceCinema> searchByQuery(@Param("query") String query);

    boolean existsByEvenement_IdEvenement(Integer idEvenement);
}