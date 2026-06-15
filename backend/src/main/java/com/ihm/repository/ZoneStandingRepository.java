package com.ihm.repository;

import com.ihm.model.ZoneStanding;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ZoneStandingRepository extends JpaRepository<ZoneStanding, Integer> {

    List<ZoneStanding> findByEvenement_IdEvenement(Integer idEvenement);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT z FROM ZoneStanding z WHERE z.idZone = :idZone")
    Optional<ZoneStanding> findByIdWithLock(@Param("idZone") Integer idZone);

    @Modifying
    @Query("UPDATE ZoneStanding z SET z.reservationsActuelles = z.reservationsActuelles + 1 WHERE z.idZone = :idZone AND (z.capacite IS NULL OR z.reservationsActuelles < z.capacite)")
    int incrementReservation(@Param("idZone") Integer idZone);

    @Modifying
    @Query("UPDATE ZoneStanding z SET z.reservationsActuelles = z.reservationsActuelles - 1 WHERE z.idZone = :idZone AND z.reservationsActuelles > 0")
    int decrementReservation(@Param("idZone") Integer idZone);
}
