package com.ihm.repository;

import com.ihm.model.Film;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FilmRepository extends JpaRepository<Film, Long> {

    Optional<Film> findByIdFilm(Long idFilm);

    List<Film> findByTitreContainingIgnoreCase(String titre);

    @Query("SELECT f FROM Film f WHERE f.idFilm IN " +
           "(SELECT s.film.idFilm FROM SeanceCinema s WHERE s.evenement.idEvenement = :idEvent)")
    Optional<Film> findByEvenementId(@Param("idEvent") Integer idEvent);

    @Query("SELECT f FROM Film f JOIN f.seances s WHERE s.dateSeance >= CURRENT_DATE ORDER BY s.dateSeance ASC")
    List<Film> findFilmsAvecSeancesAVenir();

    boolean existsByTitre(String titre);
}