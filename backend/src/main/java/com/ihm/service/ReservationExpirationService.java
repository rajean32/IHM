package com.ihm.service;

import com.ihm.model.Reservation;
import com.ihm.repository.ReservationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReservationExpirationService {

    private static final Logger log = LoggerFactory.getLogger(ReservationExpirationService.class);

    private final ReservationRepository reservationRepository;
    private final ReservationService reservationService;

    private static final int EXPIRATION_MINUTES = 10;

    public ReservationExpirationService(ReservationRepository reservationRepository,
                                         ReservationService reservationService) {
        this.reservationRepository = reservationRepository;
        this.reservationService = reservationService;
    }

    @Scheduled(fixedDelayString = "${reservation.expiration.interval:60000}")
    @Transactional
    public void expireUnpaidReservations() {
        LocalDateTime threshold = LocalDateTime.now().minusMinutes(EXPIRATION_MINUTES);
        List<Reservation> expired = reservationRepository.findUnpaidOlderThan(threshold);

        if (expired.isEmpty()) {
            log.debug("No expired unpaid reservations found");
            return;
        }

        for (Reservation reservation : expired) {
            try {
                reservationService.cancel(reservation.getIdReservation());
                log.info("Expired unpaid reservation cancelled: id={}, date={}",
                        reservation.getIdReservation(), reservation.getDateReservation());
            } catch (Exception e) {
                log.error("Failed to cancel expired reservation id={}: {}",
                        reservation.getIdReservation(), e.getMessage());
            }
        }
    }
}
