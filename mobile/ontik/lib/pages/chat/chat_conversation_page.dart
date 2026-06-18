import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/chat_service.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../core/assets/app_colors.dart';
import '../../generated/app_localizations.dart';

class ChatConversationPage extends StatefulWidget {
  final Conversation conversation;

  const ChatConversationPage({super.key, required this.conversation});

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final _chatService = ChatService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _chatService.markAsRead(widget.conversation.idConversation, userCode!);
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadSilent());
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await _loadSilent();
    setState(() => _isLoading = false);
  }

  Future<void> _loadSilent() async {
    try {
      final data = await _chatService.getMessages(widget.conversation.idConversation);
      if (!mounted) return;
      final msgs = data.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
      msgs.sort((a, b) => (a.dateEnvoi ?? DateTime.now()).compareTo(b.dateEnvoi ?? DateTime.now()));
      setState(() => _messages = msgs);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      });
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || userCode == null) return;
    _msgCtrl.clear();
    try {
      await _chatService.sendMessage(widget.conversation.idConversation, userCode!, text);
      await _loadSilent();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.participant1Nom)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.commonNoData,
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isMe = msg.expediteur == userCode;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isMe ? const Radius.circular(4) : null,
                                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                                ),
                                border: isMe ? null : Border.all(color: AppColors.divider),
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(msg.contenu, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(
                                  msg.dateEnvoi != null ? DateFormat('HH:mm').format(msg.dateEnvoi!) : '',
                                  style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textMuted),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        filled: true, fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _send,
                  ),
                ]),
              ),
            ]),
    );
  }
}
