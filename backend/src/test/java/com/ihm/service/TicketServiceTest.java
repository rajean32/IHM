package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.*;
import com.ihm.repository.*;
import com.ihm.schema.TicketDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TicketServiceTest {

    @Mock private TicketRepository ticketRepository;
    @Mock private ConcernerRepository concernerRepository;
    @Mock private EvenementRepository evenementRepository;
    @Mock private PlaceRepository placeRepository;
    @Mock private CorrespondARepository correspondARepository;
    @Mock private QRCodeService qrCodeService;
    @Mock private EvenementPlaceConfigurationRepository configRepository;
    @Mock private StandingZoneService standingZoneService;
    @Mock private ZoneStandingRepository zoneStandingRepository;
    @Mock private NotificationService notificationService;
    @Mock private ActionLogService actionLogService;

    private TicketService ticketService;

    @BeforeEach
    void setUp() {
        ticketService = new TicketService(ticketRepository, concernerRepository,
                evenementRepository, placeRepository, correspondARepository,
                qrCodeService, configRepository, standingZoneService, zoneStandingRepository,
                notificationService, actionLogService);
    }

    @Test
    void createTicket_withStandingZone_shouldIncrementCounter() {
        Evenement event = new Evenement();
        event.setIdEvenement(1);
        event.setTitre("Concert");
        event.setDateEvenement(LocalDate.now().plusDays(30));
        event.setStatut("planifie");

        ZoneStanding zone = new ZoneStanding();
        zone.setIdZone(10);
        zone.setNom("Fosse");
        zone.setCapacite(500);
        zone.setReservationsActuelles(42);
        zone.setEvenement(event);

        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT-TEST-001");
        dto.setIdZone(10);
        dto.setIdEvenement(1);
        dto.setPrix(BigDecimal.valueOf(25));

        when(ticketRepository.existsByCodeTicket("TKT-TEST-001")).thenReturn(false);
        when(evenementRepository.findByIdEvenement(1)).thenReturn(Optional.of(event));
        when(zoneStandingRepository.findById(10)).thenReturn(Optional.of(zone));
        doNothing().when(standingZoneService).incrementReservation(10);
        when(ticketRepository.save(any(Ticket.class))).thenAnswer(invocation -> invocation.getArgument(0));

        TicketDTO result = ticketService.create(dto);

        assertNotNull(result);
        assertEquals("TKT-TEST-001", result.getCodeTicket());
        verify(standingZoneService).incrementReservation(10);
    }

    @Test
    void createTicket_duplicateCode_shouldThrow() {
        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT-DUP");

        when(ticketRepository.existsByCodeTicket("TKT-DUP")).thenReturn(true);

        assertThrows(DuplicateResourceException.class, () -> ticketService.create(dto));
        verify(ticketRepository, never()).save(any());
    }

    @Test
    void createTicket_pastEvent_shouldThrow() {
        Evenement event = new Evenement();
        event.setIdEvenement(2);
        event.setTitre("Vieux Concert");
        event.setDateEvenement(LocalDate.now().minusDays(5));
        event.setStatut("planifie");

        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT-PAST");
        dto.setIdEvenement(2);

        when(ticketRepository.existsByCodeTicket("TKT-PAST")).thenReturn(false);
        when(evenementRepository.findByIdEvenement(2)).thenReturn(Optional.of(event));

        assertThrows(BadRequestException.class, () -> ticketService.create(dto));
    }

    @Test
    void createTicket_cancelledEvent_shouldThrow() {
        Evenement event = new Evenement();
        event.setIdEvenement(3);
        event.setTitre("Annule");
        event.setDateEvenement(LocalDate.now().plusDays(10));
        event.setStatut("annule");

        TicketDTO dto = new TicketDTO();
        dto.setCodeTicket("TKT-CANCEL");
        dto.setIdEvenement(3);

        when(ticketRepository.existsByCodeTicket("TKT-CANCEL")).thenReturn(false);
        when(evenementRepository.findByIdEvenement(3)).thenReturn(Optional.of(event));

        assertThrows(BadRequestException.class, () -> ticketService.create(dto));
    }

    @Test
    void validateTicket_withStandingZone_shouldReturnValid() {
        Evenement event = new Evenement();
        event.setIdEvenement(1);
        event.setTitre("Concert");

        ZoneStanding zone = new ZoneStanding();
        zone.setIdZone(10);
        zone.setNom("Fosse");
        zone.setEvenement(event);

        Client client = new Client();
        client.setNom("Dupont");
        client.setPrenoms("Jean");

        Reservation reservation = new Reservation();
        reservation.setClient(client);

        Ticket ticket = new Ticket();
        ticket.setCodeTicket("TKT-SCAN-001");
        ticket.setZoneStanding(zone);

        CorrespondA corr = new CorrespondA();
        corr.setTicket(ticket);
        corr.setReservation(reservation);

        when(ticketRepository.findByCodeTicket("TKT-SCAN-001")).thenReturn(Optional.of(ticket));
        when(correspondARepository.findByTicket_CodeTicket("TKT-SCAN-001")).thenReturn(java.util.List.of(corr));

        var response = ticketService.validateTicket("TKT-SCAN-001");

        assertTrue(response.isValid());
        assertEquals("Concert", response.getEvenementTitre());
        assertEquals("Fosse", response.getPlaceNumero());
        assertEquals("Dupont Jean", response.getClientNom());
    }

    @Test
    void generateQRCode_withStandingZone_shouldUseZoneNom() {
        Evenement event = new Evenement();
        event.setIdEvenement(1);
        event.setTitre("Concert");

        ZoneStanding zone = new ZoneStanding();
        zone.setIdZone(10);
        zone.setNom("Fosse");
        zone.setEvenement(event);

        Ticket ticket = new Ticket();
        ticket.setCodeTicket("TKT-QR-001");
        ticket.setPrix(new BigDecimal("10.00"));
        ticket.setZoneStanding(zone);

        when(ticketRepository.findByCodeTicket("TKT-QR-001")).thenReturn(Optional.of(ticket));
        when(qrCodeService.generateTicketData("TKT-QR-001", "Concert", "Fosse")).thenReturn("qr-data");
        when(qrCodeService.generateQRCodeBase64("qr-data")).thenReturn("base64img");

        var response = ticketService.generateQRCode("TKT-QR-001");

        assertEquals("TKT-QR-001", response.getCodeTicket());
        assertEquals("Concert", response.getEvenementTitre());
        assertEquals("Fosse", response.getPlaceNumero());
        assertEquals("DEBOUT", response.getTypePlace());
        assertEquals("10.00", response.getPrix());
    }

    @Test
    void getById_notFound_shouldThrow() {
        when(ticketRepository.findByCodeTicket("INVALID")).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> ticketService.getById("INVALID"));
    }
}
