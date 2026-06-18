package com.ihm.repository;

import com.ihm.model.Evenement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EvenementRepository extends JpaRepository<Evenement, Integer> {

    Optional<Evenement> findByIdEvenement(Integer idEvenement);

    List<Evenement> findByOrganisateur_CodeUtilisateur(String codeOrganisateur);

    List<Evenement> findByCategorie_CodeCategorie(String codeCategorie);

    List<Evenement> findByDateEvenementBetween(LocalDate start, LocalDate end);

    List<Evenement> findByLieu_Code(String codeLieu);

    List<Evenement> findByStatut(String statut);

    boolean existsByIdEvenement(Integer idEvenement);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement >= :today ORDER BY e.dateEvenement ASC")
    List<Evenement> findUpcomingEvents(@Param("today") LocalDate today);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Evenement> searchByTitle(@Param("query") String query);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie")
    List<Evenement> searchByTitleAndCategorie(@Param("query") String query, @Param("categorie") String categorie);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.lieu.ville = :ville")
    List<Evenement> searchByTitleAndVille(@Param("query") String query, @Param("ville") String ville);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie AND e.lieu.ville = :ville")
    List<Evenement> searchByTitleCategorieVille(@Param("query") String query, @Param("categorie") String categorie, @Param("ville") String ville);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement >= :today AND LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Evenement> searchUpcoming(@Param("today") LocalDate today, @Param("query") String query);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement >= :today AND LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie")
    List<Evenement> searchUpcomingByCategorie(@Param("today") LocalDate today, @Param("query") String query, @Param("categorie") String categorie);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement >= :today AND LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.lieu.ville = :ville")
    List<Evenement> searchUpcomingByVille(@Param("today") LocalDate today, @Param("query") String query, @Param("ville") String ville);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement >= :today AND LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie AND e.lieu.ville = :ville")
    List<Evenement> searchUpcomingFull(@Param("today") LocalDate today, @Param("query") String query, @Param("categorie") String categorie, @Param("ville") String ville);

    @Query("SELECT e FROM Evenement e WHERE e.dateEvenement BETWEEN :dateFrom AND :dateTo")
    List<Evenement> findByDateRange(@Param("dateFrom") LocalDate dateFrom, @Param("dateTo") LocalDate dateTo);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.dateEvenement BETWEEN :dateFrom AND :dateTo")
    List<Evenement> searchByTitleAndDateRange(@Param("query") String query, @Param("dateFrom") LocalDate dateFrom, @Param("dateTo") LocalDate dateTo);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie AND e.dateEvenement BETWEEN :dateFrom AND :dateTo")
    List<Evenement> searchByTitleCategorieDateRange(@Param("query") String query, @Param("categorie") String categorie, @Param("dateFrom") LocalDate dateFrom, @Param("dateTo") LocalDate dateTo);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.lieu.ville = :ville AND e.dateEvenement BETWEEN :dateFrom AND :dateTo")
    List<Evenement> searchByTitleVilleDateRange(@Param("query") String query, @Param("ville") String ville, @Param("dateFrom") LocalDate dateFrom, @Param("dateTo") LocalDate dateTo);

    @Query("SELECT e FROM Evenement e WHERE LOWER(e.titre) LIKE LOWER(CONCAT('%', :query, '%')) AND e.categorie.codeCategorie = :categorie AND e.lieu.ville = :ville AND e.dateEvenement BETWEEN :dateFrom AND :dateTo")
    List<Evenement> searchFullWithDates(@Param("query") String query, @Param("categorie") String categorie, @Param("ville") String ville, @Param("dateFrom") LocalDate dateFrom, @Param("dateTo") LocalDate dateTo);

    @Query("SELECT e.statut, COUNT(e) FROM Evenement e GROUP BY e.statut")
    List<Object[]> countByStatut();

    @Query("SELECT e.categorie.codeCategorie, COUNT(e) FROM Evenement e GROUP BY e.categorie.codeCategorie")
    List<Object[]> countByCategorie();

    @Query("SELECT e FROM Evenement e ORDER BY e.dateEvenement DESC")
    List<Evenement> findRecentEvents(org.springframework.data.domain.Pageable pageable);

    @Query("SELECT e FROM Evenement e WHERE e.datePublication IS NOT NULL ORDER BY e.datePublication DESC")
    List<Evenement> findRecentPublishedEvents(org.springframework.data.domain.Pageable pageable);

    @Query("SELECT e FROM Evenement e WHERE e.datePublication IS NOT NULL ORDER BY e.datePublication DESC")
    List<Evenement> findAllByOrderByDatePublicationDesc();

    List<Evenement> findByDateEvenementBeforeAndStatutNot(LocalDate date, String statut);

    List<Evenement> findByDateEvenementAndStatut(LocalDate date, String statut);

    @Query("SELECT COUNT(e) FROM Evenement e WHERE e.lieu IS NOT NULL AND (SELECT COUNT(p) FROM Place p WHERE p.salle.lieu.code = e.lieu.code) = 0")
    long countEventsWithoutSallePlaces();

    long countByDateEvenementBeforeAndStatutNot(LocalDate date, String statut);
}
