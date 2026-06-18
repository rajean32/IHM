import 'message_model.dart';

class Conversation {
  final int idConversation;
  final String participant1;
  final String participant2;
  final String participant1Nom;
  final String participant2Nom;
  final DateTime? dateCreation;
  final DateTime? lastMessageAt;
  final Message? lastMessage;
  final int nonLu;

  Conversation({
    required this.idConversation,
    required this.participant1,
    required this.participant2,
    required this.participant1Nom,
    required this.participant2Nom,
    this.dateCreation,
    this.lastMessageAt,
    this.lastMessage,
    this.nonLu = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      idConversation: json['idConversation'] as int,
      participant1: json['participant1'] ?? '',
      participant2: json['participant2'] ?? '',
      participant1Nom: json['participant1Nom'] ?? '',
      participant2Nom: json['participant2Nom'] ?? '',
      dateCreation: json['dateCreation'] != null ? DateTime.tryParse(json['dateCreation']) : null,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.tryParse(json['lastMessageAt']) : null,
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      nonLu: json['nonLu'] ?? 0,
    );
  }
}
