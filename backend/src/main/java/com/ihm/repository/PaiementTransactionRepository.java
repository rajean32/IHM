package com.ihm.repository;

import com.ihm.model.PaiementTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaiementTransactionRepository extends JpaRepository<PaiementTransaction, Long> {

    Optional<PaiementTransaction> findByPaiement_IdPaiement(Integer idPaiement);

    Optional<PaiementTransaction> findByReferenceTransaction(String referenceTransaction);
}