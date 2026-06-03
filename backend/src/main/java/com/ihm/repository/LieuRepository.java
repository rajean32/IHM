package com.ihm.repository;

import com.ihm.model.Lieu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LieuRepository extends JpaRepository<Lieu, String> {

    List<Lieu> findByVille(String ville);

    @Query("SELECT COUNT(l) FROM Lieu l")
    long countAllLieux();
}
