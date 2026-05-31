package com.ihm.repository;

import com.ihm.schemat.ActionLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActionLogRepository extends JpaRepository<ActionLog, Long> {

    List<ActionLog> findByCodeUtilisateurOrderByDateActionDesc(String codeUtilisateur);

    List<ActionLog> findTop20ByOrderByDateActionDesc();
}
