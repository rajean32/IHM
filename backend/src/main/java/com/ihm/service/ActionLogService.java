package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.ActionLog;
import com.ihm.model.Utilisateur;
import com.ihm.repository.ActionLogRepository;
import com.ihm.repository.ClientRepository;
import com.ihm.repository.OrganisateurRepository;
import com.ihm.repository.UtilisateurRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ActionLogService {

    private static final Logger log = LoggerFactory.getLogger(ActionLogService.class);

    private final ActionLogRepository actionLogRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final ClientRepository clientRepository;
    private final OrganisateurRepository organisateurRepository;

    public ActionLogService(ActionLogRepository actionLogRepository,
                            UtilisateurRepository utilisateurRepository,
                            ClientRepository clientRepository,
                            OrganisateurRepository organisateurRepository) {
        this.actionLogRepository = actionLogRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.clientRepository = clientRepository;
        this.organisateurRepository = organisateurRepository;
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

    // annulation d'une action (undo)
    @Transactional
    public String undoAction(Long actionLogId, String adminCode) {
        ActionLog entry = actionLogRepository.findById(actionLogId)
                .orElseThrow(() -> new ResourceNotFoundException("ActionLog", "idAction", actionLogId));

        if (entry.isReverted()) {
            throw new BadRequestException("Cette action a déjà été annulée");
        }

        String entityId = entry.getEntityId();
        String actionType = entry.getAction();
        String result;

        switch (actionType) {
            case "CREATE_USER":
                if (utilisateurRepository.existsByCodeUtilisateur(entityId)) {
                    deleteUserSilently(entityId);
                    result = "Utilisateur " + entityId + " supprimé (annulation de la création)";
                } else {
                    throw new BadRequestException("L'utilisateur " + entityId + " n'existe plus");
                }
                break;

            case "DEACTIVATE_USER":
            case "ACTIVATE_USER":
                if (utilisateurRepository.existsByCodeUtilisateur(entityId)) {
                    Utilisateur user = utilisateurRepository.findByCodeUtilisateur(entityId).orElseThrow();
                    user.setPremiereConnexion(!user.isPremiereConnexion());
                    utilisateurRepository.save(user);
                    result = "Statut de l'utilisateur " + entityId + " rétabli";
                } else {
                    throw new BadRequestException("L'utilisateur " + entityId + " n'existe plus");
                }
                break;

            default:
                throw new BadRequestException("Cette action ne peut pas être annulée : " + actionType);
        }

        entry.setReverted(true);
        actionLogRepository.save(entry);

        log.info("Admin {} undid action {} (id={}) on {}", adminCode, actionType, actionLogId, entityId);
        return result;
    }

    private void deleteUserSilently(String code) {
        String role = determineRole(utilisateurRepository.findByCodeUtilisateur(code).orElse(null));
        switch (role) {
            case "CLIENT":
                clientRepository.deleteById(code);
                break;
            case "ORGANISATEUR":
                organisateurRepository.deleteById(code);
                break;
        }
        utilisateurRepository.deleteById(code);
    }

    private String determineRole(Utilisateur user) {
        if (user == null) return "CLIENT";
        if (user instanceof com.ihm.model.Client) return "CLIENT";
        if (user instanceof com.ihm.model.Organisateur) return "ORGANISATEUR";
        return "CLIENT";
    }
}
