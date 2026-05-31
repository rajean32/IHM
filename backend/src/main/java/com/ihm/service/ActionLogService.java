package com.ihm.service;

import com.ihm.repository.ActionLogRepository;
import com.ihm.schemat.ActionLog;
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

    public void log(String codeUtilisateur, String action, String entityType, String entityId, String details) {
        ActionLog al = new ActionLog(codeUtilisateur, action, entityType, entityId, details);
        actionLogRepository.save(al);
        log.debug("Action logged: {} by {} on {} {}", action, codeUtilisateur, entityType, entityId);
    }

    public List<ActionLog> getRecentActions() {
        return actionLogRepository.findTop20ByOrderByDateActionDesc();
    }

    public List<ActionLog> getActionsByUser(String codeUtilisateur) {
        return actionLogRepository.findByCodeUtilisateurOrderByDateActionDesc(codeUtilisateur);
    }
}
