package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.*;
import com.ihm.repository.*;
import com.ihm.schema.EvenementDTO;
import com.ihm.schema.EvenementCaracteristiqueValeurDTO;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EvenementServiceTest {

    @Mock private EvenementRepository evenementRepository;
    @Mock private CategorieRepository categorieRepository;
    @Mock private LieuRepository lieuRepository;
    @Mock private OrganisateurRepository organisateurRepository;
    @Mock private ConcernerRepository concernerRepository;
    @Mock private PlaceRepository placeRepository;
    @Mock private TicketRepository ticketRepository;
    @Mock private CorrespondARepository correspondARepository;
    @Mock private SalleRepository salleRepository;
    @Mock private EvenementPlaceConfigurationRepository configRepository;
    @Mock private CaracteristiqueRepository caracteristiqueRepository;
    @Mock private EvenementCaracteristiqueValeurRepository valeurRepository;
    @Mock private ZoneStandingRepository zoneStandingRepository;
    @Mock private ReservationRepository reservationRepository;
    @Mock private StandingZoneService standingZoneService;
    @Mock private PaiementService paiementService;
    @Mock private NotificationService notificationService;
    @Mock private EntityManager entityManager;

    private EvenementService evenementService;

    @BeforeEach
    void setUp() {
        evenementService = new EvenementService(evenementRepository, categorieRepository,
                lieuRepository, organisateurRepository, concernerRepository,
                placeRepository, ticketRepository, correspondARepository,
                salleRepository, configRepository, caracteristiqueRepository,
                valeurRepository, zoneStandingRepository, reservationRepository,
                standingZoneService, paiementService, notificationService);
        ReflectionTestUtils.setField(evenementService, "entityManager", entityManager);
    }

    @Test
    void createEvenement_withCaracteristiques_shouldSaveValues() {
        Categorie categorie = new Categorie();
        categorie.setCodeCategorie("CINEMA");

        Organisateur organisateur = new Organisateur();
        organisateur.setCodeUtilisateur("ORG-001");

        Lieu lieu = new Lieu();
        lieu.setCode("LIEU-001");
        lieu.setNomLieu("Gaumont");

        Caracteristique carac = new Caracteristique();
        carac.setIdCaracteristique(1);
        carac.setNom("Genre");
        carac.setTypeDonnee("text");
        carac.setObligatoire(true);

        EvenementCaracteristiqueValeurDTO caracVal = new EvenementCaracteristiqueValeurDTO();
        caracVal.setIdCaracteristique(1);
        caracVal.setValeur("Action");

        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Film Test");
        dto.setCodeCategorie("CINEMA");
        dto.setCodeLieu("LIEU-001");
        dto.setDateEvenement(LocalDate.now().plusDays(10));
        dto.setCodeOrganisateur("ORG-001");
        dto.setCaracteristiqueValeurs(List.of(caracVal));

        Evenement savedEvent = new Evenement();
        savedEvent.setIdEvenement(100);
        savedEvent.setOrganisateur(organisateur);
        savedEvent.setTitre("Film Test");

        when(categorieRepository.findByCodeCategorie("CINEMA")).thenReturn(Optional.of(categorie));
        when(lieuRepository.findById("LIEU-001")).thenReturn(Optional.of(lieu));
        when(organisateurRepository.findByCodeUtilisateur("ORG-001")).thenReturn(Optional.of(organisateur));
        when(caracteristiqueRepository.findById(1)).thenReturn(Optional.of(carac));
        when(evenementRepository.save(any(Evenement.class))).thenReturn(savedEvent);

        EvenementDTO result = evenementService.create(dto);

        assertNotNull(result);
        assertEquals("Film Test", result.getTitre());
        verify(valeurRepository).save(any(EvenementCaracteristiqueValeur.class));
    }

    @Test
    void createEvenement_missingRequiredCaracteristique_shouldThrow() {
        Categorie categorie = new Categorie();
        categorie.setCodeCategorie("CINEMA");

        Organisateur organisateur = new Organisateur();
        organisateur.setCodeUtilisateur("ORG-001");

        Lieu lieu = new Lieu();
        lieu.setCode("LIEU-001");

        Caracteristique carac = new Caracteristique();
        carac.setIdCaracteristique(2);
        carac.setNom("Realisateur");
        carac.setTypeDonnee("text");
        carac.setObligatoire(true);

        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Film Sans Real");
        dto.setCodeCategorie("CINEMA");
        dto.setCodeLieu("LIEU-001");
        dto.setDateEvenement(LocalDate.now().plusDays(5));
        dto.setCodeOrganisateur("ORG-001");
        dto.setCaracteristiqueValeurs(List.of());

        when(categorieRepository.findByCodeCategorie("CINEMA")).thenReturn(Optional.of(categorie));
        when(lieuRepository.findById("LIEU-001")).thenReturn(Optional.of(lieu));
        when(organisateurRepository.findByCodeUtilisateur("ORG-001")).thenReturn(Optional.of(organisateur));
        when(caracteristiqueRepository.findByCategorieCodeCategorieOrderByOrdreAffichageAsc("CINEMA")).thenReturn(List.of(carac));

        assertThrows(BadRequestException.class, () -> evenementService.create(dto));
    }

    @Test
    void createEvenement_withTypeAgencementDebout_shouldAllowNullSalle() {
        Categorie categorie = new Categorie();
        categorie.setCodeCategorie("CONCERT");

        Organisateur organisateur = new Organisateur();
        organisateur.setCodeUtilisateur("ORG-002");

        Lieu lieu = new Lieu();
        lieu.setCode("LIEU-001");
        lieu.setNomLieu("Parc des Expos");

        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Concert Debout");
        dto.setCodeCategorie("CONCERT");
        dto.setCodeLieu("LIEU-001");
        dto.setDateEvenement(LocalDate.now().plusDays(20));
        dto.setCodeOrganisateur("ORG-002");
        dto.setTypeAgencement(TypeAgencement.DEBOUT_SANS_LIMITE);

        Evenement savedEvent = new Evenement();
        savedEvent.setIdEvenement(200);
        savedEvent.setOrganisateur(organisateur);
        savedEvent.setTitre("Concert Debout");
        savedEvent.setTypeAgencement(TypeAgencement.DEBOUT_SANS_LIMITE);

        when(categorieRepository.findByCodeCategorie("CONCERT")).thenReturn(Optional.of(categorie));
        when(lieuRepository.findById("LIEU-001")).thenReturn(Optional.of(lieu));
        when(organisateurRepository.findByCodeUtilisateur("ORG-002")).thenReturn(Optional.of(organisateur));
        when(evenementRepository.save(any(Evenement.class))).thenReturn(savedEvent);

        EvenementDTO result = evenementService.create(dto);

        assertNotNull(result);
        assertEquals(TypeAgencement.DEBOUT_SANS_LIMITE, result.getTypeAgencement());
        verify(evenementRepository).save(argThat(e ->
                e.getTypeAgencement() == TypeAgencement.DEBOUT_SANS_LIMITE
        ));
    }

    @Test
    void createEvenement_withoutOrganisateur_shouldThrow() {
        Categorie categorie = new Categorie();
        categorie.setCodeCategorie("CAT");

        Lieu lieu = new Lieu();
        lieu.setCode("LIEU-001");

        EvenementDTO dto = new EvenementDTO();
        dto.setTitre("Event");
        dto.setCodeCategorie("CAT");
        dto.setCodeLieu("LIEU-001");
        dto.setDateEvenement(LocalDate.now().plusDays(1));
        dto.setCodeOrganisateur("INVALID");

        when(categorieRepository.findByCodeCategorie("CAT")).thenReturn(Optional.of(categorie));
        when(lieuRepository.findById("LIEU-001")).thenReturn(Optional.of(lieu));
        when(organisateurRepository.findByCodeUtilisateur("INVALID")).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> evenementService.create(dto));
    }

    @Test
    void deleteEvenement_shouldCleanUp() {
        Evenement event = new Evenement();
        event.setIdEvenement(5);
        event.setTitre("Event à supprimer");

        var mockedQuery = mock(jakarta.persistence.Query.class);

        when(evenementRepository.existsByIdEvenement(5)).thenReturn(true);
        when(zoneStandingRepository.findByEvenement_IdEvenement(5)).thenReturn(List.of());
        when(entityManager.createQuery(anyString())).thenReturn(mockedQuery);
        when(mockedQuery.setParameter(anyString(), any())).thenReturn(mockedQuery);

        evenementService.delete(5);

        verify(valeurRepository).deleteByEvenementIdEvenement(5);
        verify(evenementRepository).deleteById(5);
    }
}
