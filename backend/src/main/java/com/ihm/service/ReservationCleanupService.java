package com.ihm.service;

import com.ihm.repository.PlaceRepository;
import com.ihm.schemat.Place;
import com.ihm.schemat.StatutPlace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReservationCleanupService {

    private static final Logger log = LoggerFactory.getLogger(ReservationCleanupService.class);

    private static final long EXPIRATION_MINUTES = 10;

    private final PlaceRepository placeRepository;

    public ReservationCleanupService(PlaceRepository placeRepository) {
        this.placeRepository = placeRepository;
    }

    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void releaseExpiredPendingPlaces() {
        LocalDateTime expiry = LocalDateTime.now().minusMinutes(EXPIRATION_MINUTES);
        List<Place> expired = placeRepository.findExpiredPending(expiry);

        if (!expired.isEmpty()) {
            for (Place place : expired) {
                place.setStatut(StatutPlace.DISPONIBLE);
                place.setDateMiseEnAttente(null);
                placeRepository.save(place);
            }
            log.info("Released {} expired EN_ATTENTE places", expired.size());
        }
    }
}
