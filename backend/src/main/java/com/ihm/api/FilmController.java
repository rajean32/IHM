package com.ihm.api;

import com.ihm.model.Film;
import com.ihm.model.SeanceCinema;
import com.ihm.schema.ApiResponse;
import com.ihm.repository.FilmRepository;
import com.ihm.repository.SeanceCinemaRepository;
import com.ihm.exception.ResourceNotFoundException;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/films")
public class FilmController {

    private static final Logger log = LoggerFactory.getLogger(FilmController.class);

    private final FilmRepository filmRepository;
    private final SeanceCinemaRepository seanceCinemaRepository;

    public FilmController(FilmRepository filmRepository, SeanceCinemaRepository seanceCinemaRepository) {
        this.filmRepository = filmRepository;
        this.seanceCinemaRepository = seanceCinemaRepository;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Film>>> getAll() {
        log.info("GET /api/films");
        return ResponseEntity.ok(ApiResponse.success(200, "Films récupérés", filmRepository.findAll()));
    }

    @GetMapping("/a-venir")
    public ResponseEntity<ApiResponse<List<Film>>> getFilmsAVenir() {
        log.info("GET /api/films/a-venir");
        return ResponseEntity.ok(ApiResponse.success(200, "Films à venir", filmRepository.findFilmsAvecSeancesAVenir()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Film>> getById(@PathVariable Long id) {
        log.info("GET /api/films/{}", id);
        Film film = filmRepository.findByIdFilm(id)
                .orElseThrow(() -> new ResourceNotFoundException("Film", "idFilm", id));
        return ResponseEntity.ok(ApiResponse.success(200, "Film récupéré", film));
    }

    @GetMapping("/evenement/{idEvenement}")
    public ResponseEntity<ApiResponse<Film>> getByEvenement(@PathVariable Integer idEvenement) {
        log.info("GET /api/films/evenement/{}", idEvenement);
        Film film = filmRepository.findByEvenementId(idEvenement)
                .orElseThrow(() -> new ResourceNotFoundException("Film", "evenement", idEvenement));
        return ResponseEntity.ok(ApiResponse.success(200, "Film récupéré", film));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Film>> create(@Valid @RequestBody Film film) {
        log.info("POST /api/films - titre: {}", film.getTitre());
        if (filmRepository.existsByTitre(film.getTitre())) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, "Un film avec ce titre existe déjà", null));
        }
        Film saved = filmRepository.save(film);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Film créé", saved));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Film>> update(@PathVariable Long id, @Valid @RequestBody Film film) {
        log.info("PUT /api/films/{}", id);
        Film existing = filmRepository.findByIdFilm(id)
                .orElseThrow(() -> new ResourceNotFoundException("Film", "idFilm", id));
        existing.setTitre(film.getTitre());
        existing.setSynopsis(film.getSynopsis());
        existing.setRealisateur(film.getRealisateur());
        existing.setActeurs(film.getActeurs());
        existing.setDureeMinutes(film.getDureeMinutes());
        existing.setBandeAnnonce(film.getBandeAnnonce());
        Film saved = filmRepository.save(existing);
        return ResponseEntity.ok(ApiResponse.success(200, "Film mis à jour", saved));
    }

    @PostMapping("/{id}/affiche")
    public ResponseEntity<ApiResponse<Void>> uploadAffiche(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        log.info("POST /api/films/{}/affiche", id);
        Film film = filmRepository.findByIdFilm(id)
                .orElseThrow(() -> new ResourceNotFoundException("Film", "idFilm", id));
        try {
            film.setAffiche(file.getBytes());
            filmRepository.save(film);
            return ResponseEntity.ok(ApiResponse.success(200, "Affiche téléchargée"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "Erreur lors du téléchargement", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        log.info("DELETE /api/films/{}", id);
        if (!filmRepository.existsById(id)) {
            throw new ResourceNotFoundException("Film", "idFilm", id);
        }
        filmRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(200, "Film supprimé"));
    }

    // Gestion des séances
    @GetMapping("/{id}/seances")
    public ResponseEntity<ApiResponse<List<SeanceCinema>>> getSeances(@PathVariable Long id) {
        log.info("GET /api/films/{}/seances", id);
        return ResponseEntity.ok(ApiResponse.success(200, "Séances récupérées", 
                seanceCinemaRepository.findByFilm_IdFilm(id)));
    }

    @PostMapping("/{id}/seances")
    public ResponseEntity<ApiResponse<SeanceCinema>> addSeance(@PathVariable Long id, @Valid @RequestBody SeanceCinema seance) {
        log.info("POST /api/films/{}/seances", id);
        Film film = filmRepository.findByIdFilm(id)
                .orElseThrow(() -> new ResourceNotFoundException("Film", "idFilm", id));
        seance.setFilm(film);
        SeanceCinema saved = seanceCinemaRepository.save(seance);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Séance ajoutée", saved));
    }
}