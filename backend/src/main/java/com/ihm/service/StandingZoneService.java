package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Evenement;
import com.ihm.model.TypeAgencement;
import com.ihm.model.ZoneStanding;
import com.ihm.repository.EvenementRepository;
import com.ihm.repository.ZoneStandingRepository;
import com.ihm.schema.ZoneStandingDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class StandingZoneService {

    private static final Logger log = LoggerFactory.getLogger(StandingZoneService.class);

    private final ZoneStandingRepository zoneStandingRepository;
    private final EvenementRepository evenementRepository;

    public StandingZoneService(ZoneStandingRepository zoneStandingRepository,
                               EvenementRepository evenementRepository) {
        this.zoneStandingRepository = zoneStandingRepository;
        this.evenementRepository = evenementRepository;
    }

    @Transactional(readOnly = true)
    public List<ZoneStandingDTO> getZonesForEvent(Integer idEvenement) {
        return zoneStandingRepository.findByEvenement_IdEvenement(idEvenement)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ZoneStandingDTO createZone(Integer idEvenement, ZoneStandingDTO dto) {
        Evenement event = evenementRepository.findByIdEvenement(idEvenement)
                .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", idEvenement));

        if (dto.getCapacite() != null && dto.getCapacite() <= 0) {
            throw new BadRequestException("Capacity must be positive or null for unlimited");
        }
        if (dto.getPrix() == null || dto.getPrix().signum() < 0) {
            throw new BadRequestException("Price must be non-negative");
        }

        ZoneStanding zone = new ZoneStanding();
        zone.setEvenement(event);
        zone.setNom(dto.getNom());
        zone.setCapacite(dto.getCapacite());
        zone.setPrix(dto.getPrix());
        zone.setStatut("ACTIVE");
        zone.setReservationsActuelles(0);

        ZoneStanding saved = zoneStandingRepository.save(zone);
        log.info("Standing zone created: id={}, event={}, nom={}, capacite={}, prix={}",
                saved.getIdZone(), idEvenement, saved.getNom(), saved.getCapacite(), saved.getPrix());
        return toDTO(saved);
    }

    @Transactional
    public ZoneStandingDTO updateZone(Integer idZone, ZoneStandingDTO dto) {
        ZoneStanding zone = zoneStandingRepository.findById(idZone)
                .orElseThrow(() -> new ResourceNotFoundException("ZoneStanding", "idZone", idZone));

        if (dto.getNom() != null) zone.setNom(dto.getNom());
        if (dto.getCapacite() != null) {
            if (dto.getCapacite() <= 0) throw new BadRequestException("Capacity must be positive");
            if (dto.getCapacite() < zone.getReservationsActuelles()) {
                throw new BadRequestException("Cannot reduce capacity below current reservations");
            }
            zone.setCapacite(dto.getCapacite());
        }
        if (dto.getPrix() != null) {
            if (dto.getPrix().signum() < 0) throw new BadRequestException("Price must be non-negative");
            zone.setPrix(dto.getPrix());
        }
        if (dto.getStatut() != null) zone.setStatut(dto.getStatut());

        ZoneStanding saved = zoneStandingRepository.save(zone);
        log.info("Standing zone updated: id={}", idZone);
        return toDTO(saved);
    }

    @Transactional
    public void deleteZone(Integer idZone) {
        if (!zoneStandingRepository.existsById(idZone)) {
            throw new ResourceNotFoundException("ZoneStanding", "idZone", idZone);
        }
        zoneStandingRepository.deleteById(idZone);
        log.info("Standing zone deleted: id={}", idZone);
    }

    @Transactional
    public void incrementReservation(Integer idZone) {
        ZoneStanding zone = zoneStandingRepository.findById(idZone)
                .orElseThrow(() -> new ResourceNotFoundException("ZoneStanding", "idZone", idZone));

        if (zone.getCapacite() != null && zone.getReservationsActuelles() >= zone.getCapacite()) {
            throw new BadRequestException("Standing zone '" + zone.getNom() + "' is full (" +
                    zone.getReservationsActuelles() + "/" + zone.getCapacite() + ")");
        }
        int updated = zoneStandingRepository.incrementReservation(idZone);
        if (updated == 0) {
            throw new BadRequestException("Failed to increment reservation: zone may be full");
        }
    }

    @Transactional
    public void decrementReservation(Integer idZone) {
        zoneStandingRepository.decrementReservation(idZone);
    }

    public boolean isZoneAvailable(Integer idZone) {
        ZoneStanding zone = zoneStandingRepository.findById(idZone).orElse(null);
        if (zone == null) return false;
        if (!"ACTIVE".equals(zone.getStatut())) return false;
        if (zone.getCapacite() != null && zone.getReservationsActuelles() >= zone.getCapacite()) return false;
        return true;
    }

    public ZoneStandingDTO toDTO(ZoneStanding zone) {
        ZoneStandingDTO dto = new ZoneStandingDTO();
        dto.setIdZone(zone.getIdZone());
        dto.setIdEvenement(zone.getEvenement().getIdEvenement());
        dto.setNom(zone.getNom());
        dto.setCapacite(zone.getCapacite());
        dto.setPrix(zone.getPrix());
        dto.setStatut(zone.getStatut());
        dto.setReservationsActuelles(zone.getReservationsActuelles());
        if (zone.getCapacite() != null) {
            dto.setPlacesDisponibles(zone.getCapacite() - zone.getReservationsActuelles());
        }
        return dto;
    }
}
