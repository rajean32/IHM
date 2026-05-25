package com.ihm.repository;

import com.ihm.schemat.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ClientRepository extends JpaRepository<Client, String> {

    Optional<Client> findByCodeUtilisateur(String codeUtilisateur);

    boolean existsByCodeUtilisateur(String codeUtilisateur);
}
