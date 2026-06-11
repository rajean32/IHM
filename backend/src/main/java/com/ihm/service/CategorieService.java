package com.ihm.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.CaracteristiqueDTO;
import com.ihm.schema.CategorieDTO;
import com.ihm.repository.CaracteristiqueRepository;
import com.ihm.repository.CategorieRepository;
import com.ihm.repository.SalleRepository;
import com.ihm.repository.SalleTypeEvenementRepository;
import com.ihm.model.Caracteristique;
import com.ihm.model.Categorie;
import com.ihm.model.Salle;
import com.ihm.model.SalleTypeEvenement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class CategorieService {

    private static final Logger log = LoggerFactory.getLogger(CategorieService.class);

    private final CategorieRepository categorieRepository;
    private final CaracteristiqueRepository caracteristiqueRepository;
    private final SalleRepository salleRepository;
    private final SalleTypeEvenementRepository salleTypeEvenementRepository;
    private final ObjectMapper objectMapper;

    public CategorieService(CategorieRepository categorieRepository,
                            CaracteristiqueRepository caracteristiqueRepository,
                            SalleRepository salleRepository,
                            SalleTypeEvenementRepository salleTypeEvenementRepository,
                            ObjectMapper objectMapper) {
        this.categorieRepository = categorieRepository;
        this.caracteristiqueRepository = caracteristiqueRepository;
        this.salleRepository = salleRepository;
        this.salleTypeEvenementRepository = salleTypeEvenementRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public List<CategorieDTO> getAll() {
        log.debug("Fetching all categories");
        return categorieRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CategorieDTO getById(String code) {
        log.debug("Fetching category by code: {}", code);
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        return toDTO(cat);
    }

    @Transactional
    public CategorieDTO create(CategorieDTO dto) {
        log.debug("Creating category: {}", dto.getCodeCategorie());
        if (categorieRepository.existsByCodeCategorie(dto.getCodeCategorie())) {
            throw new DuplicateResourceException("Categorie", "codeCategorie", dto.getCodeCategorie());
        }
        Categorie cat = new Categorie(dto.getCodeCategorie(), dto.getNomCategorie());
        cat.setDescription(dto.getDescription());
        cat.setDateCreation(LocalDateTime.now());
        Categorie saved = categorieRepository.save(cat);
        log.info("Category created: {}", saved.getCodeCategorie());
        return toDTOSimple(saved);
    }

    @Transactional
    public CategorieDTO update(String code, CategorieDTO dto) {
        log.debug("Updating category: {}", code);
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        if (dto.getNomCategorie() != null) cat.setNomCategorie(dto.getNomCategorie());
        if (dto.getDescription() != null) cat.setDescription(dto.getDescription());
        Categorie saved = categorieRepository.save(cat);
        log.info("Category updated: {}", code);
        return toDTOSimple(saved);
    }

    @Transactional
    public void delete(String code) {
        log.debug("Deleting category: {}", code);
        if (!categorieRepository.existsByCodeCategorie(code)) {
            throw new ResourceNotFoundException("Categorie", "codeCategorie", code);
        }
        salleTypeEvenementRepository.deleteByCategorieCodeCategorie(code);
        caracteristiqueRepository.deleteByCategorieCodeCategorie(code);
        categorieRepository.deleteById(code);
        log.info("Category deleted: {}", code);
    }

    @Transactional
    public void addSalleType(String codeCategorie, String numeroSalle) {
        Categorie cat = categorieRepository.findByCodeCategorie(codeCategorie)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", codeCategorie));
        Salle salle = salleRepository.findByNumeroSalle(numeroSalle)
                .orElseThrow(() -> new ResourceNotFoundException("Salle", "numeroSalle", numeroSalle));
        SalleTypeEvenement.SalleTypeEvenementId id = new SalleTypeEvenement.SalleTypeEvenementId(numeroSalle, codeCategorie);
        if (!salleTypeEvenementRepository.existsById(id)) {
            SalleTypeEvenement ste = new SalleTypeEvenement();
            ste.setId(id);
            ste.setSalle(salle);
            ste.setCategorie(cat);
            salleTypeEvenementRepository.save(ste);
            log.info("SalleTypeEvenement added: salle={}, categorie={}", numeroSalle, codeCategorie);
        }
    }

    @Transactional
    public void removeSalleType(String codeCategorie, String numeroSalle) {
        SalleTypeEvenement.SalleTypeEvenementId id = new SalleTypeEvenement.SalleTypeEvenementId(numeroSalle, codeCategorie);
        if (salleTypeEvenementRepository.existsById(id)) {
            salleTypeEvenementRepository.deleteById(id);
            log.info("SalleTypeEvenement removed: salle={}, categorie={}", numeroSalle, codeCategorie);
        }
    }

    @Transactional(readOnly = true)
    public String getSpecificConfig(String code) {
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        return cat.getSpecificConfig();
    }

    @Transactional
    public void updateSpecificConfig(String code, Map<String, Object> config) {
        log.debug("Updating specific config for category: {}", code);
        Categorie cat = categorieRepository.findByCodeCategorie(code)
                .orElseThrow(() -> new ResourceNotFoundException("Categorie", "codeCategorie", code));
        try {
            cat.setSpecificConfig(objectMapper.writeValueAsString(config));
            categorieRepository.save(cat);
            log.info("Specific config updated for category: {}", code);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize config", e);
        }
    }

    private CategorieDTO toDTO(Categorie cat) {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie(cat.getCodeCategorie());
        dto.setNomCategorie(cat.getNomCategorie());
        dto.setDescription(cat.getDescription());
        dto.setDateCreation(cat.getDateCreation());
        dto.setSpecificConfig(cat.getSpecificConfig());
        if (cat.getCaracteristiques() != null && !cat.getCaracteristiques().isEmpty()) {
            dto.setCaracteristiques(cat.getCaracteristiques().stream()
                    .map(c -> {
                        CaracteristiqueDTO cdto = new CaracteristiqueDTO();
                        cdto.setIdCaracteristique(c.getIdCaracteristique());
                        cdto.setNom(c.getNom());
                        cdto.setTypeDonnee(c.getTypeDonnee());
                        cdto.setObligatoire(c.isObligatoire());
                        cdto.setOrdreAffichage(c.getOrdreAffichage());
                        cdto.setOptions(c.getOptions());
                        cdto.setCodeCategorie(c.getCategorie().getCodeCategorie());
                        return cdto;
                    }).collect(Collectors.toList()));
        }
        if (cat.getSalleTypes() != null && !cat.getSalleTypes().isEmpty()) {
            dto.setSalleTypeCodes(cat.getSalleTypes().stream()
                    .map(st -> st.getSalle().getNumeroSalle())
                    .collect(Collectors.toList()));
        }
        return dto;
    }

    private CategorieDTO toDTOSimple(Categorie cat) {
        CategorieDTO dto = new CategorieDTO();
        dto.setCodeCategorie(cat.getCodeCategorie());
        dto.setNomCategorie(cat.getNomCategorie());
        dto.setDescription(cat.getDescription());
        dto.setDateCreation(cat.getDateCreation());
        return dto;
    }
}
