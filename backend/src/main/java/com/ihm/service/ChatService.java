package com.ihm.service;

import com.ihm.exception.BadRequestException;
import com.ihm.exception.ResourceNotFoundException;
import com.ihm.model.Conversation;
import com.ihm.model.Message;
import com.ihm.repository.ConversationRepository;
import com.ihm.repository.MessageRepository;
import com.ihm.repository.UtilisateurRepository;
import com.ihm.schema.ConversationDTO;
import com.ihm.schema.MessageDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChatService {

    private static final Logger log = LoggerFactory.getLogger(ChatService.class);

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatService(ConversationRepository conversationRepository,
                       MessageRepository messageRepository,
                       UtilisateurRepository utilisateurRepository,
                       SimpMessagingTemplate messagingTemplate) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public ConversationDTO createOrGetConversation(String participant1, String participant2) {
        if (participant1.equals(participant2)) {
            throw new BadRequestException("Cannot create conversation with yourself");
        }
        if (!utilisateurRepository.existsByCodeUtilisateur(participant1)) {
            throw new ResourceNotFoundException("Utilisateur", "code", participant1);
        }
        if (!utilisateurRepository.existsByCodeUtilisateur(participant2)) {
            throw new ResourceNotFoundException("Utilisateur", "code", participant2);
        }

        Conversation existing = conversationRepository.findByParticipants(participant1, participant2).orElse(null);
        if (existing != null) {
            return toConversationDTO(existing, participant1);
        }

        Conversation conv = new Conversation(participant1, participant2);
        Conversation saved = conversationRepository.save(conv);
        log.info("Conversation created between {} and {}", participant1, participant2);
        return toConversationDTO(saved, participant1);
    }

    @Transactional
    public MessageDTO sendMessage(Long conversationId, String expediteur, String contenu) {
        if (contenu == null || contenu.isBlank()) {
            throw new BadRequestException("Message content cannot be empty");
        }
        Conversation conv = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResourceNotFoundException("Conversation", "id", conversationId));

        String destinataire = conv.getParticipant1().equals(expediteur) ? conv.getParticipant2() : conv.getParticipant1();

        Message msg = new Message(conversationId, expediteur, destinataire, contenu);
        Message saved = messageRepository.save(msg);

        conv.setLastMessageAt(LocalDateTime.now());
        conversationRepository.save(conv);

        MessageDTO dto = toMessageDTO(saved);

        try {
            messagingTemplate.convertAndSendToUser(destinataire, "/queue/chat", dto);
        } catch (Exception e) {
            log.warn("WebSocket push failed for user {}: {}", destinataire, e.getMessage());
        }

        log.debug("Message sent in conversation {} from {} to {}", conversationId, expediteur, destinataire);
        return dto;
    }

    @Transactional(readOnly = true)
    public List<ConversationDTO> getConversations(String userId) {
        if (!utilisateurRepository.existsByCodeUtilisateur(userId)) {
            throw new ResourceNotFoundException("Utilisateur", "code", userId);
        }
        return conversationRepository.findByParticipant(userId).stream()
                .map(conv -> {
                    ConversationDTO dto = toConversationDTO(conv, userId);
                    List<Message> lastMsgs = messageRepository.findByIdConversationOrderByDateEnvoiDesc(
                            conv.getIdConversation(), PageRequest.of(0, 1));
                    if (!lastMsgs.isEmpty()) {
                        dto.setLastMessage(toMessageDTO(lastMsgs.get(0)));
                    }
                    dto.setNonLu(messageRepository.countByIdConversationAndDestinataireAndLuFalse(
                            conv.getIdConversation(), userId));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<MessageDTO> getMessages(Long conversationId, int page, int size) {
        if (!conversationRepository.existsById(conversationId)) {
            throw new ResourceNotFoundException("Conversation", "id", conversationId);
        }
        return messageRepository.findByIdConversationOrderByDateEnvoiDesc(
                        conversationId, PageRequest.of(page, size)).stream()
                .map(this::toMessageDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(Long conversationId, String userId) {
        messageRepository.markAsRead(conversationId, userId);
        log.debug("Messages marked as read for user {} in conversation {}", userId, conversationId);
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(String userId) {
        return messageRepository.countUnreadByDestinataire(userId);
    }

    public String getOtherParticipantNom(Conversation conv, String userId) {
        String otherCode = conv.getParticipant1().equals(userId) ? conv.getParticipant2() : conv.getParticipant1();
        return utilisateurRepository.findByCodeUtilisateur(otherCode)
                .map(u -> u.getPrenoms() + " " + u.getNom())
                .orElse(otherCode);
    }

    private ConversationDTO toConversationDTO(Conversation conv, String currentUserId) {
        ConversationDTO dto = new ConversationDTO();
        dto.setIdConversation(conv.getIdConversation());
        dto.setParticipant1(conv.getParticipant1());
        dto.setParticipant2(conv.getParticipant2());
        dto.setParticipant1Nom(getOtherParticipantNom(conv, currentUserId));
        dto.setDateCreation(conv.getDateCreation());
        dto.setLastMessageAt(conv.getLastMessageAt());
        return dto;
    }

    private MessageDTO toMessageDTO(Message msg) {
        MessageDTO dto = new MessageDTO();
        dto.setIdMessage(msg.getIdMessage());
        dto.setIdConversation(msg.getIdConversation());
        dto.setExpediteur(msg.getExpediteur());
        dto.setDestinataire(msg.getDestinataire());
        dto.setContenu(msg.getContenu());
        dto.setDateEnvoi(msg.getDateEnvoi());
        dto.setLu(msg.isLu());
        return dto;
    }
}
