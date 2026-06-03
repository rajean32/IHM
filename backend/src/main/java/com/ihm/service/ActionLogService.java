package com.ihm.service;

import com.ihm.repository.ActionLogRepository;
import com.ihm.model.ActionLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActionLogService {

    private static final Logger log = LoggerFactory.getLogger(ActionLogService.class);

    private final ActionLogRepository actionLogRepository;

    public ActionLogService(ActionLogRepository actionLogRepository) {
        this.actionLogRepository = actionLogRepository;
    }

    // enregistrement d'une action
    public void log(String codeUtilisateur, String action, String entityType, String entityId, String details) {
        ActionLog al = new ActionLog(codeUtilisateur, action, entityType, entityId, details);
        actionLogRepository.save(al);
        log.debug("Action logged: {} by {} on {} {}", action, codeUtilisateur, entityType, entityId);
    }

    // actions recentes
    public List<ActionLog> getRecentActions() {
        return actionLogRepository.findTop20ByOrderByDateActionDesc();
    }

    // actions d'un utilisateur
    public List<ActionLog> getActionsByUser(String codeUtilisateur) {
        return actionLogRepository.findByCodeUtilisateurOrderByDateActionDesc(codeUtilisateur);
    }
}
