package com.ihm.api;

import com.ihm.schema.ApiResponse;
import com.ihm.schema.ConversationDTO;
import com.ihm.schema.MessageDTO;
import com.ihm.service.ChatService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private static final Logger log = LoggerFactory.getLogger(ChatController.class);

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping("/conversations")
    public ResponseEntity<ApiResponse<ConversationDTO>> createConversation(@RequestBody Map<String, String> body) {
        String p1 = body.get("participant1");
        String p2 = body.get("participant2");
        log.info("POST /api/chat/conversations - {} ⇄ {}", p1, p2);
        ConversationDTO data = chatService.createOrGetConversation(p1, p2);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Conversation created", data));
    }

    @PostMapping("/messages")
    public ResponseEntity<ApiResponse<MessageDTO>> sendMessage(@RequestBody Map<String, Object> body) {
        Long conversationId = Long.valueOf(body.get("idConversation").toString());
        String expediteur = (String) body.get("expediteur");
        String contenu = (String) body.get("contenu");
        log.info("POST /api/chat/messages - conv: {}, from: {}", conversationId, expediteur);
        MessageDTO data = chatService.sendMessage(conversationId, expediteur, contenu);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(201, "Message sent", data));
    }

    @GetMapping("/conversations/{userId}")
    public ResponseEntity<ApiResponse<List<ConversationDTO>>> getConversations(@PathVariable String userId) {
        log.info("GET /api/chat/conversations/{}", userId);
        List<ConversationDTO> data = chatService.getConversations(userId);
        return ResponseEntity.ok(ApiResponse.success(200, "Conversations fetched", data));
    }

    @GetMapping("/messages/{conversationId}")
    public ResponseEntity<ApiResponse<List<MessageDTO>>> getMessages(
            @PathVariable Long conversationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        log.info("GET /api/chat/messages/{} (page={}, size={})", conversationId, page, size);
        List<MessageDTO> data = chatService.getMessages(conversationId, page, size);
        return ResponseEntity.ok(ApiResponse.success(200, "Messages fetched", data));
    }

    @PatchMapping("/conversations/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String userId = body.get("userId");
        log.info("PATCH /api/chat/conversations/{}/read - user: {}", id, userId);
        chatService.markAsRead(id, userId);
        return ResponseEntity.ok(ApiResponse.success(200, "Messages marked as read"));
    }

    @GetMapping("/unread/{userId}")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@PathVariable String userId) {
        log.info("GET /api/chat/unread/{}", userId);
        long count = chatService.getUnreadCount(userId);
        return ResponseEntity.ok(ApiResponse.success(200, "Unread count fetched", count));
    }
}
