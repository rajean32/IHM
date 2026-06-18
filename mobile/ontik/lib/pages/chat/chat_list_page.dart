import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/dio_config.dart';
import '../../core/services/chat_service.dart';
import '../../models/conversation_model.dart';
import '../../core/assets/app_colors.dart';
import '../../generated/app_localizations.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _chatService = ChatService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (userCode == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await _chatService.getConversations(userCode!);
      if (!mounted) return;
      setState(() {
        _conversations = data.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_conversations.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.commonNoData, style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final conv = _conversations[i];
          final otherName = conv.participant1Nom;
          final lastMsg = conv.lastMessage?.contenu ?? '';
          final time = conv.lastMessageAt != null
              ? DateFormat('dd/MM HH:mm').format(conv.lastMessageAt!)
              : '';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              if (conv.nonLu > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Text('${conv.nonLu}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChatConversationPage(conversation: conv),
            )).then((_) => _load()),
          );
        },
      ),
    );
  }
}
