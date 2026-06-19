package com.ihm.service;

import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Ville;
import com.ihm.repository.VilleRepository;
import com.ihm.schema.VilleDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class VilleService {

    private static final Logger log = LoggerFactory.getLogger(VilleService.class);

    private final VilleRepository villeRepository;

    public VilleService(VilleRepository villeRepository) {
        this.villeRepository = villeRepository;
    }

    @PostConstruct
    @Transactional
    public void initializeDefaultVilles() {
        if (villeRepository.count() > 0) {
            log.debug("Villes already seeded ({} found)", villeRepository.count());
            return;
        }
        log.info("Seeding default Madagascar cities...");
        List<Ville> defaultVilles = List.of(
            new Ville("TNR", "Antananarivo", "Analamanga"),
            new Ville("TMA", "Toamasina", "Atsinanana"),
            new Ville("ATB", "Antsirabe", "Vakinankaratra"),
            new Ville("FIA", "Fianarantsoa", "Haute Matsiatra"),
            new Ville("MJV", "Mahajanga", "Boeny"),
            new Ville("TLE", "Toliara", "Atsimo-Andrefana"),
            new Ville("ANS", "Antsiranana", "Diana"),
            new Ville("NSB", "Nosy Be", "Diana"),
            new Ville("AMB", "Ambovombe", "Androy"),
            new Ville("MOR", "Morondava", "Menabe"),
            new Ville("AVO", "Ambalavao", "Haute Matsiatra"),
            new Ville("AMS", "Ambositra", "Amoron'i Mania"),
            new Ville("ANP", "Andapa", "Sava"),
            new Ville("ANT", "Antalaha", "Sava"),
            new Ville("FAR", "Farafangana", "Atsimo-Atsinanana"),
            new Ville("IHO", "Ihosy", "Ihorombe"),
            new Ville("MAE", "Maevatanana", "Betsiboka"),
            new Ville("MAI", "Maintirano", "Melaky"),
            new Ville("MNK", "Manakara", "Fitovinany"),
            new Ville("MNJ", "Mananjary", "Vatovavy"),
            new Ville("MND", "Mandritsara", "Sofia"),
            new Ville("MAR", "Maroantsetra", "Analanjirofo"),
            new Ville("MIA", "Miandrivazo", "Menabe"),
            new Ville("MRM", "Morombe", "Atsimo-Andrefana"),
            new Ville("SAM", "Sambava", "Sava"),
            new Ville("SOA", "Soanierana Ivongo", "Analanjirofo"),
            new Ville("FTD", "Taolagnaro", "Anosy"),
            new Ville("TSI", "Tsiroanomandidy", "Bongolava"),
            new Ville("VAT", "Vatomandry", "Atsinanana"),
            new Ville("ABJ", "Ambanja", "Diana"),
            new Ville("ABY", "Amboasary", "Anosy"),
            new Ville("BEF", "Befandriana", "Sofia"),
            new Ville("BEL", "Belo sur Tsiribihina", "Menabe"),
            new Ville("BER", "Beroroha", "Atsimo-Andrefana"),
            new Ville("BES", "Besalampy", "Melaky"),
            new Ville("BET", "Betafo", "Vakinankaratra"),
            new Ville("BTK", "Betioky", "Atsimo-Andrefana"),
            new Ville("BEA", "Bealanana", "Sofia"),
            new Ville("FAN", "Fandriana", "Amoron'i Mania"),
            new Ville("IAK", "Iakora", "Ihorombe"),
            new Ville("IFA", "Ifanadiana", "Vatovavy"),
            new Ville("ANL", "Analalava", "Sofia"),
            new Ville("AND", "Andoany", "Diana"),
            new Ville("ADR", "Andramasina", "Analamanga"),
            new Ville("ANJ", "Anjozorobe", "Analamanga"),
            new Ville("ANK", "Ankavandra", "Melaky"),
            new Ville("ANZ", "Ankazobe", "Analamanga"),
            new Ville("ARI", "Arivonimamo", "Itasy"),
            new Ville("MIV", "Miarinarivo", "Itasy"),
            new Ville("SVN", "Soavinandriana", "Itasy"),
            new Ville("ALM", "Ambatondrazaka", "Alaotra-Mangoro"),
            new Ville("MRA", "Moramanga", "Alaotra-Mangoro"),
            new Ville("ADL", "Andilamena", "Alaotra-Mangoro"),
            new Ville("MJD", "Manjakandriana", "Analamanga"),
            new Ville("FEA", "Fenoarivo Atsinanana", "Analanjirofo"),
            new Ville("VHP", "Vohipeno", "Fitovinany"),
            new Ville("BLH", "Beloha", "Androy"),
            new Ville("BKL", "Bekily", "Androy"),
            new Ville("TSH", "Tsihombe", "Androy"),
            new Ville("AMP", "Ampanihy", "Atsimo-Andrefana"),
            new Ville("SKH", "Sakaraha", "Atsimo-Andrefana"),
            new Ville("VNG", "Vangaindrano", "Atsimo-Atsinanana"),
            new Ville("MDY", "Midongy", "Atsimo-Atsinanana"),
            new Ville("TSA", "Tsaratanana", "Betsiboka"),
            new Ville("MRV", "Marovoay", "Boeny"),
            new Ville("MIT", "Mitsinjo", "Boeny"),
            new Ville("FVB", "Fenoarivobe", "Bongolava"),
            new Ville("ABL", "Ambilobe", "Diana"),
            new Ville("MRF", "Morafenobe", "Melaky"),
            new Ville("VOH", "Vohemar", "Sava"),
            new Ville("ANH", "Antsohihy", "Sofia"),
            new Ville("BOR", "Boriziny", "Sofia"),
            new Ville("FTS", "Faratsiho", "Vakinankaratra"),
            new Ville("ATF", "Antanifotsy", "Vakinankaratra"),
            new Ville("NVK", "Nosy Varika", "Vatovavy")
        );
        villeRepository.saveAll(defaultVilles);
        log.info("Seeded {} Madagascar cities", defaultVilles.size());
    }

    public List<VilleDTO> getAllActive() {
        return villeRepository.findByActifTrueOrderByNomAsc().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<VilleDTO> getAll() {
        return villeRepository.findAllByOrderByNomAsc().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<VilleDTO> search(String query) {
        return villeRepository.findByNomContainingIgnoreCase(query).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public VilleDTO getByCode(String code) {
        Ville ville = villeRepository.findById(code)
                .orElseThrow(() -> new ResourceNotFoundException("Ville", "code", code));
        return toDTO(ville);
    }

    @Transactional
    public VilleDTO create(VilleDTO dto) {
        if (villeRepository.existsById(dto.getCode())) {
            throw new DuplicateResourceException("Ville", "code", dto.getCode());
        }
        Ville ville = new Ville();
        ville.setCode(dto.getCode().toUpperCase());
        ville.setNom(dto.getNom());
        ville.setRegion(dto.getRegion());
        ville.setActif(dto.getActif() != null ? dto.getActif() : true);
        Ville saved = villeRepository.save(ville);
        log.info("City created: {} ({})", saved.getNom(), saved.getCode());
        return toDTO(saved);
    }

    @Transactional
    public VilleDTO update(String code, VilleDTO dto) {
        Ville ville = villeRepository.findById(code)
                .orElseThrow(() -> new ResourceNotFoundException("Ville", "code", code));
        if (dto.getNom() != null) ville.setNom(dto.getNom());
        if (dto.getRegion() != null) ville.setRegion(dto.getRegion());
        if (dto.getActif() != null) ville.setActif(dto.getActif());
        Ville saved = villeRepository.save(ville);
        log.info("City updated: {} ({})", saved.getNom(), saved.getCode());
        return toDTO(saved);
    }

    @Transactional
    public void delete(String code) {
        if (!villeRepository.existsById(code)) {
            throw new ResourceNotFoundException("Ville", "code", code);
        }
        villeRepository.deleteById(code);
        log.info("City deleted: {}", code);
    }

    @Transactional
    public void reseed() {
        villeRepository.deleteAll();
        initializeDefaultVilles();
    }

    public Ville resolveOrCreateVille(String villeCode, String villeNom) {
        if (villeCode != null && !villeCode.isBlank()) {
            return villeRepository.findById(villeCode.toUpperCase())
                    .orElse(null);
        }
        if (villeNom != null && !villeNom.isBlank()) {
            return villeRepository.findByNomIgnoreCase(villeNom.trim())
                    .orElseGet(() -> createFromNom(villeNom.trim()));
        }
        return null;
    }

    private Ville createFromNom(String nom) {
        if (nom == null || nom.isBlank()) return null;
        String baseCode = nom.toUpperCase().replaceAll("[^A-Z]", "");
        baseCode = baseCode.length() > 3 ? baseCode.substring(0, 3) : baseCode;
        if (baseCode.length() < 2) baseCode = "C" + baseCode;
        String code = baseCode;
        int suffix = 1;
        while (villeRepository.existsById(code)) {
            code = baseCode + suffix;
            suffix++;
        }
        Ville ville = new Ville(code, nom);
        return villeRepository.save(ville);
    }

    private VilleDTO toDTO(Ville ville) {
        VilleDTO dto = new VilleDTO();
        dto.setCode(ville.getCode());
        dto.setNom(ville.getNom());
        dto.setRegion(ville.getRegion());
        dto.setActif(ville.isActif());
        return dto;
    }
}
