package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.DuplicateResourceException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.schema.PaiementDTO;
import com.ihm.schema.PaiementRequestDTO;
import com.ihm.schema.PaiementResultDTO;
import com.ihm.repository.*;
import com.ihm.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PaiementService {

    private static final Logger log = LoggerFactory.getLogger(PaiementService.class);

    private final PaiementRepository paiementRepository;
    private final ReservationRepository reservationRepository;
    private final ReductionService reductionService;
    private final PaiementTransactionRepository paiementTransactionRepository;
    private final TicketRepository ticketRepository;
    private final CorrespondARepository correspondARepository;
    private final EvenementPlaceConfigurationRepository configRepository;
    private final ClientRepository clientRepository;
    private final ConcernerRepository concernerRepository;
    private final PlaceRepository placeRepository;
    private final EvenementRepository evenementRepository;
    private final ActionLogService actionLogService;

    public PaiementService(PaiementRepository paiementRepository,
                           ReservationRepository reservationRepository,
                           ReductionService reductionService,
                           PaiementTransactionRepository paiementTransactionRepository,
                           TicketRepository ticketRepository,
                           CorrespondARepository correspondARepository,
                           EvenementPlaceConfigurationRepository configRepository,
                           ClientRepository clientRepository,
                           ConcernerRepository concernerRepository,
                           PlaceRepository placeRepository,
                           EvenementRepository evenementRepository,
                           ActionLogService actionLogService) {
        this.paiementRepository = paiementRepository;
        this.reservationRepository = reservationRepository;
        this.reductionService = reductionService;
        this.paiementTransactionRepository = paiementTransactionRepository;
        this.ticketRepository = ticketRepository;
        this.correspondARepository = correspondARepository;
        this.configRepository = configRepository;
        this.clientRepository = clientRepository;
        this.concernerRepository = concernerRepository;
        this.placeRepository = placeRepository;
        this.evenementRepository = evenementRepository;
        this.actionLogService = actionLogService;
    }

    public List<PaiementDTO> getAll() {
        log.debug("Fetching all payments");
        return paiementRepository.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public List<PaiementDTO> getByClient(String codeClient) {
        log.debug("Fetching payments by client: {}", codeClient);
        return paiementRepository.findByClient(codeClient)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public PaiementDTO getById(Integer id) {
        log.debug("Fetching payment by id: {}", id);
        Paiement paiement = paiementRepository.findByIdPaiement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paiement", "idPaiement", id));
        return toDTO(paiement);
    }

    @Transactional
    public PaiementDTO create(PaiementDTO dto) {
        log.debug("Creating payment for reservation: {}", dto.getIdReservation());
        if (paiementRepository.existsByReservation_IdReservation(dto.getIdReservation())) {
            throw new DuplicateResourceException("Paiement", "idReservation", dto.getIdReservation());
        }
        Reservation reservation = reservationRepository.findByIdReservation(dto.getIdReservation())
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", dto.getIdReservation()));
        Paiement paiement = new Paiement();
        paiement.setMontant(dto.getMontant());
        paiement.setDatePaiement(dto.getDatePaiement());
        paiement.setModePaiement(dto.getModePaiement());
        paiement.setReservation(reservation);
        Paiement saved = paiementRepository.save(paiement);
        log.info("Payment created: id={}", saved.getIdPaiement());
        return toDTO(saved);
    }

    @Transactional
    public PaiementDTO update(Integer id, PaiementDTO dto) {
        log.debug("Updating payment: {}", id);
        Paiement paiement = paiementRepository.findByIdPaiement(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paiement", "idPaiement", id));

        if (dto.getMontant() != null) paiement.setMontant(dto.getMontant());
        if (dto.getModePaiement() != null) paiement.setModePaiement(dto.getModePaiement());
        if (dto.getDatePaiement() != null) paiement.setDatePaiement(dto.getDatePaiement());

        Paiement saved = paiementRepository.save(paiement);
        log.info("Payment updated: id={}", id);
        return toDTO(saved);
    }

    @Transactional
    public PaiementDTO.PaiementStatus processWebhook(String reservationId, BigDecimal amount, String modePaiement, String status) {
        log.debug("Processing payment webhook for reservation: {}", reservationId);
        Integer idReservation = Integer.parseInt(reservationId);

        if ("SUCCESS".equalsIgnoreCase(status)) {
            if (!paiementRepository.existsByReservation_IdReservation(idReservation)) {
                Reservation reservation = reservationRepository.findByIdReservation(idReservation)
                        .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", idReservation));

                Paiement paiement = new Paiement();
                paiement.setMontant(amount);
                paiement.setDatePaiement(LocalDateTime.now());
                paiement.setModePaiement(modePaiement);
                paiement.setReservation(reservation);
                paiementRepository.save(paiement);
                log.info("Payment created via webhook for reservation: {}", idReservation);
            }

            Paiement paiement = paiementRepository.findByReservation_IdReservation(idReservation).orElse(null);
            PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
            response.setIdPaiement(paiement != null ? paiement.getIdPaiement() : null);
            response.setIdReservation(idReservation);
            response.setMontant(amount);
            response.setModePaiement(modePaiement);
            response.setDatePaiement(paiement != null ? paiement.getDatePaiement() : LocalDateTime.now());
            response.setStatus("CONFIRMED");
            return response;
        } else {
            PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
            response.setIdReservation(idReservation);
            response.setMontant(amount);
            response.setModePaiement(modePaiement);
            response.setStatus("FAILED");
            return response;
        }
    }

    public PaiementDTO.PaiementStatus getPaymentStatus(Integer idReservation) {
        log.debug("Fetching payment status for reservation: {}", idReservation);
        Paiement paiement = paiementRepository.findByReservation_IdReservation(idReservation)
                .orElse(null);

        PaiementDTO.PaiementStatus response = new PaiementDTO.PaiementStatus();
        if (paiement != null) {
            response.setIdPaiement(paiement.getIdPaiement());
            response.setIdReservation(idReservation);
            response.setMontant(paiement.getMontant());
            response.setModePaiement(paiement.getModePaiement());
            response.setDatePaiement(paiement.getDatePaiement());
            response.setStatus("PAID");
        } else {
            response.setIdReservation(idReservation);
            response.setStatus("PENDING");
        }
        return response;
    }

    @Transactional
    public PaiementResultDTO processPaymentWithReduction(PaiementRequestDTO request) {
        log.info("Processing payment for client: {}, type: {}", request.getCodeClient(), request.getTypePaiement());

        Client client = clientRepository.findByCodeUtilisateur(request.getCodeClient())
                .orElseThrow(() -> new ResourceNotFoundException("Client", "codeClient", request.getCodeClient()));

        BigDecimal montantInitial = request.getTickets().stream()
                .map(t -> t.getPrix() != null ? t.getPrix() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Integer idEvenement = request.getTickets().isEmpty() ? null : request.getTickets().get(0).getIdEvenement();

        BigDecimal reduction = reductionService.calculerReduction(
                request.getCodeClient(),
                idEvenement,
                montantInitial,
                request.getCodePromo(),
                request.getEstEtudiant()
        );

        BigDecimal montantFinal = montantInitial.subtract(reduction).max(BigDecimal.ZERO);
        String typeReduction = reduction.compareTo(BigDecimal.ZERO) > 0 ? "APPLIQUEE" : null;

        log.info("Montant initial: {}, Réduction: {}, Montant final: {}", montantInitial, reduction, montantFinal);

        if (montantFinal.compareTo(BigDecimal.ZERO) < 0) {
            throw new BadRequestException("Le montant du paiement ne peut pas être négatif");
        }

        validerMoyenPaiement(request);

        List<Ticket> tickets = new ArrayList<>();
        for (PaiementRequestDTO.TicketItem item : request.getTickets()) {
            EvenementPlaceConfiguration config = configRepository
                    .findByEvenement_IdEvenementAndPlace_NumeroPlace(item.getIdEvenement(), item.getNumeroPlace())
                    .orElse(null);
            
            if (config != null && !"DISPONIBLE".equals(config.getStatut())) {
                throw new BadRequestException("La place " + item.getNumeroPlace() + " n'est plus disponible");
            }

            Ticket ticket = new Ticket();
            ticket.setCodeTicket(item.getCodeTicket());
            ticket.setPrix(item.getPrix());
            Ticket saved = ticketRepository.save(ticket);
            tickets.add(saved);

            ConcernerId concernerId = new ConcernerId(item.getIdEvenement(), item.getCodeTicket(), item.getNumeroPlace());
            Concerner concerner = new Concerner();
            concerner.setId(concernerId);
            
            Evenement event = evenementRepository.findByIdEvenement(item.getIdEvenement())
                    .orElseThrow(() -> new ResourceNotFoundException("Evenement", "idEvenement", item.getIdEvenement()));
            concerner.setEvenement(event);
            concerner.setTicket(saved);
            
            Place place = placeRepository.findByNumeroPlace(item.getNumeroPlace())
                    .orElseThrow(() -> new ResourceNotFoundException("Place", "numeroPlace", item.getNumeroPlace()));
            concerner.setPlace(place);
            concernerRepository.save(concerner);

            if (config != null) {
                config.setStatut("RESERVEE");
                configRepository.save(config);
            }
        }

        Reservation reservation = new Reservation();
        reservation.setDateReservation(LocalDateTime.now());
        reservation.setClient(client);
        Reservation savedReservation = reservationRepository.save(reservation);

        for (Ticket ticket : tickets) {
            CorrespondAId corrId = new CorrespondAId(ticket.getCodeTicket(), savedReservation.getIdReservation());
            CorrespondA corr = new CorrespondA();
            corr.setId(corrId);
            corr.setTicket(ticket);
            corr.setReservation(savedReservation);
            correspondARepository.save(corr);
        }

        Paiement paiement = new Paiement();
        paiement.setMontant(montantFinal);
        paiement.setDatePaiement(LocalDateTime.now());
        paiement.setModePaiement(request.getTypePaiement());
        paiement.setReservation(savedReservation);
        Paiement savedPaiement = paiementRepository.save(paiement);

        PaiementTransaction transaction = new PaiementTransaction();
        transaction.setPaiement(savedPaiement);
        transaction.setDateTransaction(LocalDateTime.now());

        switch (request.getTypePaiement().toUpperCase()) {
            case "MVOLA":
            case "ORANGE":
            case "AIRTEL":
                transaction.setReferenceTransaction(request.getReferenceTransaction());
                transaction.setNumeroTelephone(request.getNumeroTelephone());
                transaction.setNomComplet(request.getNomComplet());
                transaction.setStatut("CONFIRME");
                transaction.setMessageReponse("Paiement " + request.getTypePaiement() + " confirmé");
                break;
            case "CARTE":
                transaction.setStatut("CONFIRME");
                transaction.setMessageReponse("Paiement par carte bancaire simulé - Transaction validée");
                if (request.getCarte() != null && request.getCarte().getNumeroCarte() != null) {
                    String numero = request.getCarte().getNumeroCarte().replaceAll("\\s", "");
                    String derniers4 = numero.length() >= 4 ? numero.substring(numero.length() - 4) : "****";
                    transaction.setMessageReponse("Paiement par carte ****" + derniers4 + " - Transaction validée");
                }
                break;
            default:
                throw new BadRequestException("Type de paiement non supporté: " + request.getTypePaiement());
        }

        paiementTransactionRepository.save(transaction);

        if (request.getCodePromo() != null && !request.getCodePromo().isBlank()) {
            reductionService.incrementUtilisation(request.getCodePromo());
        }

        actionLogService.log(request.getCodeClient(), "PAIEMENT_EFFECTUE", "Reservation",
                String.valueOf(savedReservation.getIdReservation()),
                "Type: " + request.getTypePaiement() + ", Montant: " + montantFinal + ", Réduction: " + reduction);

        log.info("Payment completed. Reservation ID: {}, Amount: {}", savedReservation.getIdReservation(), montantFinal);

        PaiementResultDTO result = new PaiementResultDTO();
        result.setSuccess(true);
        result.setMessage("Paiement effectué avec succès");
        result.setIdReservation(savedReservation.getIdReservation());
        result.setIdPaiement(savedPaiement.getIdPaiement());
        result.setMontantInitial(montantInitial);
        result.setReductionAppliquee(reduction);
        result.setMontantFinal(montantFinal);
        result.setTypeReduction(typeReduction);
        result.setStatutPaiement("CONFIRME");
        result.setDatePaiement(LocalDateTime.now());

        return result;
    }

    private void validerMoyenPaiement(PaiementRequestDTO request) {
        String type = request.getTypePaiement().toUpperCase();
        
        switch (type) {
            case "MVOLA":
            case "ORANGE":
            case "AIRTEL":
                if (request.getReferenceTransaction() == null || request.getReferenceTransaction().isBlank()) {
                    throw new BadRequestException("La référence de transaction est requise pour " + type);
                }
                if (request.getNumeroTelephone() == null || request.getNumeroTelephone().isBlank()) {
                    throw new BadRequestException("Le numéro de téléphone est requis pour " + type);
                }
                if (!request.getNumeroTelephone().matches("^[0-9]{9,15}$")) {
                    throw new BadRequestException("Numéro de téléphone invalide");
                }
                break;
            case "CARTE":
                if (request.getCarte() == null) {
                    throw new BadRequestException("Les informations de carte bancaire sont requises");
                }
                validerCarteBancaire(request.getCarte());
                break;
            default:
                throw new BadRequestException("Type de paiement non supporté: " + type);
        }
    }

    private void validerCarteBancaire(PaiementRequestDTO.CarteBancaireDTO carte) {
        String numero = carte.getNumeroCarte().replaceAll("\\s", "");
        if (numero.length() != 16) {
            throw new BadRequestException("Le numéro de carte doit contenir 16 chiffres");
        }
        if (!numero.matches("\\d{16}")) {
            throw new BadRequestException("Format de numéro de carte invalide");
        }

        String[] parts = carte.getDateExpiration().split("/");
        if (parts.length != 2) {
            throw new BadRequestException("Format de date d'expiration invalide (MM/YY)");
        }
        try {
            int mois = Integer.parseInt(parts[0]);
            int annee = Integer.parseInt(parts[1]);
            if (mois < 1 || mois > 12) {
                throw new BadRequestException("Mois invalide");
            }
            LocalDateTime now = LocalDateTime.now();
            int anneeActuelle = now.getYear() % 100;
            int moisActuel = now.getMonthValue();
            if (annee < anneeActuelle || (annee == anneeActuelle && mois < moisActuel)) {
                throw new BadRequestException("Carte expirée");
            }
        } catch (NumberFormatException e) {
            throw new BadRequestException("Format de date d'expiration invalide");
        }

        if (carte.getCvv() == null || carte.getCvv().length() < 3 || carte.getCvv().length() > 4) {
            throw new BadRequestException("CVV invalide");
        }
        if (!carte.getCvv().matches("\\d{3,4}")) {
            throw new BadRequestException("Le CVV doit contenir uniquement des chiffres");
        }

        if (carte.getNomTitulaire() == null || carte.getNomTitulaire().isBlank()) {
            throw new BadRequestException("Le nom du titulaire est requis");
        }
    }

    @Transactional
    public PaiementResultDTO rembourserReservation(Integer idReservation, String codeClient, boolean isAnnulationEvenement) {
        log.info("Demande de remboursement pour réservation: {}, annulation événement: {}", idReservation, isAnnulationEvenement);

        Reservation reservation = reservationRepository.findByIdReservation(idReservation)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", "idReservation", idReservation));

        if (!reservation.getClient().getCodeUtilisateur().equals(codeClient)) {
            throw new BadRequestException("Cette réservation ne vous appartient pas");
        }

        Paiement paiement = paiementRepository.findByReservation_IdReservation(idReservation)
                .orElseThrow(() -> new BadRequestException("Aucun paiement trouvé pour cette réservation"));

        PaiementTransaction transaction = paiementTransactionRepository.findByPaiement_IdPaiement(paiement.getIdPaiement())
                .orElse(null);
        if (transaction != null && "REMBOURSE".equals(transaction.getStatut())) {
            throw new BadRequestException("Ce paiement a déjà été remboursé");
        }

        boolean peutRembourser = false;
        String motif = "";

        if (isAnnulationEvenement) {
            peutRembourser = true;
            motif = "Annulation de l'événement";
        } else {
            LocalDate dateEvenement = null;
            List<CorrespondA> correspondances = correspondARepository.findByReservation_IdReservation(idReservation);
            for (CorrespondA ca : correspondances) {
                List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
                for (Concerner c : concerners) {
                    dateEvenement = c.getEvenement().getDateEvenement();
                    break;
                }
                if (dateEvenement != null) break;
            }
            
            if (dateEvenement != null && dateEvenement.equals(LocalDate.now())) {
                peutRembourser = false;
                motif = "Annulation le jour de l'événement - Remboursement non disponible";
            } else {
                peutRembourser = true;
                motif = "Annulation par le client";
            }
        }

        if (!peutRembourser) {
            PaiementResultDTO result = new PaiementResultDTO();
            result.setSuccess(false);
            result.setMessage(motif);
            result.setIdReservation(idReservation);
            result.setStatutPaiement("NON_REMBOURSE");
            return result;
        }

        for (CorrespondA ca : reservation.getCorrespondances()) {
            List<Concerner> concerners = concernerRepository.findByTicket_CodeTicket(ca.getTicket().getCodeTicket());
            for (Concerner c : concerners) {
                EvenementPlaceConfiguration config = configRepository
                        .findByEvenement_IdEvenementAndPlace_NumeroPlace(
                                c.getEvenement().getIdEvenement(), c.getPlace().getNumeroPlace())
                        .orElse(null);
                if (config != null) {
                    config.setStatut("DISPONIBLE");
                    configRepository.save(config);
                }
            }
        }

        if (transaction != null) {
            transaction.setStatut("REMBOURSE");
            transaction.setMessageReponse(motif + " - Remboursement effectué le " + LocalDateTime.now());
            paiementTransactionRepository.save(transaction);
        }

        actionLogService.log(codeClient, "REMBOURSEMENT", "Reservation",
                String.valueOf(idReservation), "Montant: " + paiement.getMontant() + ", Motif: " + motif);

        log.info("Remboursement effectué pour réservation: {}, Montant: {}", idReservation, paiement.getMontant());

        PaiementResultDTO result = new PaiementResultDTO();
        result.setSuccess(true);
        result.setMessage("Remboursement effectué avec succès - " + motif);
        result.setIdReservation(idReservation);
        result.setIdPaiement(paiement.getIdPaiement());
        result.setMontantFinal(paiement.getMontant());
        result.setStatutPaiement("REMBOURSE");
        result.setDatePaiement(LocalDateTime.now());

        return result;
    }

    @Transactional(readOnly = true)
    public PaiementResultDTO verifierTransactionMobile(String referenceTransaction, String typePaiement) {
        log.info("Vérification transaction {} - Type: {}", referenceTransaction, typePaiement);

        PaiementTransaction transaction = paiementTransactionRepository.findByReferenceTransaction(referenceTransaction)
                .orElse(null);

        PaiementResultDTO result = new PaiementResultDTO();
        result.setSuccess(false);
        result.setMessage("Transaction non trouvée");

        if (transaction != null) {
            result.setSuccess("CONFIRME".equals(transaction.getStatut()));
            result.setMessage("Statut: " + transaction.getStatut() + " - " + transaction.getMessageReponse());
            result.setStatutPaiement(transaction.getStatut());
            if (transaction.getPaiement() != null) {
                result.setIdPaiement(transaction.getPaiement().getIdPaiement());
                result.setMontantFinal(transaction.getPaiement().getMontant());
                if (transaction.getPaiement().getReservation() != null) {
                    result.setIdReservation(transaction.getPaiement().getReservation().getIdReservation());
                }
            }
        }

        return result;
    }

    @Transactional
    public void delete(Integer id) {
        log.debug("Deleting payment: {}", id);
        if (!paiementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Paiement", "idPaiement", id);
        }
        paiementRepository.deleteById(id);
        log.info("Payment deleted: id={}", id);
    }

    private PaiementDTO toDTO(Paiement paiement) {
        PaiementDTO dto = new PaiementDTO();
        dto.setIdPaiement(paiement.getIdPaiement());
        dto.setMontant(paiement.getMontant());
        dto.setDatePaiement(paiement.getDatePaiement());
        dto.setModePaiement(paiement.getModePaiement());
        dto.setIdReservation(paiement.getReservation().getIdReservation());
        return dto;
    }
}