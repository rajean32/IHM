package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.CategorieDTO;
import com.ihm.repository.CategorieRepository;
import com.ihm.model.Categorie;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CategorieService {

    private static final Logger log = LoggerFactory.getLogger(CategorieService.class);

    private final CategorieRepository categorieRepository;

    public CategorieService(CategorieRepository categorieRepository) {
        this.categorieRepository = categorieRepository;
    }

    // recuperation de toutes les categories
    public List<CategorieDTO> getAll() {
        log.debug("Fetching all categories");
        return categorieRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // recuperation d'une categorie
    public CategorieDTO getById(String code) {
        log.debug("Fetching category by code: {}", code);
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        return toDTO(cat);
    }

    // creation d'une categorie
    @Transactional
    public CategorieDTO create(CategorieDTO dto) {
        log.debug("Creating category: {}", dto.getCodeCategorie());
        if (categorieRepository.existsByCodeCategorie(dto.getCodeCategorie())) {
            throw new DuplicateResourceException("Categorie", "codeCategorie", dto.getCodeCategorie());
        }
        Categorie cat = new Categorie(dto.getCodeCategorie(), dto.getNomCategorie());
        Categorie saved = categorieRepository.save(cat);
        log.info("Category created: {}", saved.getCodeCategorie());
        return toDTO(saved);
    }

    // mise a jour d'une categorie
    @Transactional
    public CategorieDTO update(String code, CategorieDTO dto) {
        log.debug("Updating category: {}", code);
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        if (dto.getNomCategorie() != null) {
            cat.setNomCategorie(dto.getNomCategorie());
        }
        Categorie saved = categorieRepository.save(cat);
        log.info("Category updated: {}", code);
        return toDTO(saved);
    }

    // suppression d'une categorie
    @Transactional
    public void delete(String code) {
        log.debug("Deleting category: {}", code);
        if (!categorieRepository.existsByCodeCategorie(code)) {
            throw new ResourceNotFoundException("Categorie", "codeCategorie", code);
        }
        categorieRepository.deleteById(code);
        log.info("Category deleted: {}", code);
    }

    private CategorieDTO toDTO(Categorie cat) {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie(cat.getCodeCategorie());
        dto.setNomCategorie(cat.getNomCategorie());
        return dto;
    }
}
