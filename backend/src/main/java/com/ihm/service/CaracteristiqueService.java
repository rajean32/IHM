package com.ihm.service;

import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Caracteristique;
import com.ihm.model.Categorie;
import com.ihm.repository.CaracteristiqueRepository;
import com.ihm.repository.CategorieRepository;
import com.ihm.schema.CaracteristiqueDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CaracteristiqueService {

    private static final Logger log = LoggerFactory.getLogger(CaracteristiqueService.class);

    private final CaracteristiqueRepository caracteristiqueRepository;
    private final CategorieRepository categorieRepository;

    public CaracteristiqueService(CaracteristiqueRepository caracteristiqueRepository,
                                   CategorieRepository categorieRepository) {
        this.caracteristiqueRepository = caracteristiqueRepository;
        this.categorieRepository = categorieRepository;
    }

    @Transactional(readOnly = true)
    public List<CaracteristiqueDTO> getByCategorie(String codeCategorie) {
        return caracteristiqueRepository.findByCategorieCodeCategorieOrderByOrdreAffichageAsc(codeCategorie)
                .stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CaracteristiqueDTO getById(Integer id) {
        Caracteristique c = caracteristiqueRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Caracteristique", "id", id));
        return toDTO(c);
    }

    @Transactional
    public CaracteristiqueDTO create(CaracteristiqueDTO dto) {
        Categorie cat = categorieRepository.findByCodeCategorie(dto.getCodeCategorie())
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", dto.getCodeCategorie()));
        Caracteristique c = new Caracteristique();
        c.setNom(dto.getNom());
        c.setTypeDonnee(dto.getTypeDonnee());
        c.setObligatoire(dto.isObligatoire());
        c.setOrdreAffichage(dto.getOrdreAffichage());
        c.setOptions(dto.getOptions());
        c.setCategorie(cat);
        Caracteristique saved = caracteristiqueRepository.save(c);
        log.info("Caracteristique created: id={}, nom={}", saved.getIdCaracteristique(), saved.getNom());
        return toDTO(saved);
    }

    @Transactional
    public CaracteristiqueDTO update(Integer id, CaracteristiqueDTO dto) {
        Caracteristique c = caracteristiqueRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Caracteristique", "id", id));
        if (dto.getNom() != null) c.setNom(dto.getNom());
        if (dto.getTypeDonnee() != null) c.setTypeDonnee(dto.getTypeDonnee());
        c.setObligatoire(dto.isObligatoire());
        if (dto.getOrdreAffichage() != null) c.setOrdreAffichage(dto.getOrdreAffichage());
        if (dto.getOptions() != null) c.setOptions(dto.getOptions());
        Caracteristique saved = caracteristiqueRepository.save(c);
        log.info("Caracteristique updated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public void delete(Integer id) {
        if (!caracteristiqueRepository.existsById(id)) {
            throw new ResourceNotFoundException("Caracteristique", "id", id);
        }
        caracteristiqueRepository.deleteById(id);
        log.info("Caracteristique deleted: id={}", id);
    }

    private CaracteristiqueDTO toDTO(Caracteristique c) {
        CaracteristiqueDTO dto = new CaracteristiqueDTO();
        dto.setIdCaracteristique(c.getIdCaracteristique());
        dto.setNom(c.getNom());
        dto.setTypeDonnee(c.getTypeDonnee());
        dto.setObligatoire(c.isObligatoire());
        dto.setOrdreAffichage(c.getOrdreAffichage());
        dto.setOptions(c.getOptions());
        dto.setCodeCategorie(c.getCategorie().getCodeCategorie());
        return dto;
    }
}
