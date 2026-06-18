package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Avis;
import com.ihm.repository.AvisRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AvisService {

    private static final Logger log = LoggerFactory.getLogger(AvisService.class);

    private final AvisRepository avisRepository;

    public AvisService(AvisRepository avisRepository) {
        this.avisRepository = avisRepository;
    }

    @Transactional
    public Avis create(Integer idEvenement, String codeClient, Integer note, String commentaire) {
        if (note < 1 || note > 5) {
            throw new BadRequestException("Note must be between 1 and 5");
        }
        if (avisRepository.existsByIdEvenementAndCodeClient(idEvenement, codeClient)) {
            throw new BadRequestException("Vous avez déjà noté cet événement");
        }

        Avis avis = new Avis(idEvenement, codeClient, note, commentaire);
        Avis saved = avisRepository.save(avis);
        log.info("Avis created for event {} by client {}: note={}", idEvenement, codeClient, note);
        return saved;
    }

    @Transactional(readOnly = true)
    public List<Avis> getByEvenement(Integer idEvenement) {
        return avisRepository.findByIdEvenementOrderByDateCreationDesc(idEvenement);
    }

    @Transactional(readOnly = true)
    public Double getNoteMoyenne(Integer idEvenement) {
        return avisRepository.avgNoteByEvenement(idEvenement);
    }

    @Transactional(readOnly = true)
    public long getNombreAvis(Integer idEvenement) {
        return avisRepository.countByIdEvenement(idEvenement);
    }
}
