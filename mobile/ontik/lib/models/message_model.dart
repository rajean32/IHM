class Message {
  final int? idMessage;
  final int idConversation;
  final String expediteur;
  final String destinataire;
  final String contenu;
  final DateTime? dateEnvoi;
  final bool lu;

  Message({
    this.idMessage,
    required this.idConversation,
    required this.expediteur,
    required this.destinataire,
    required this.contenu,
    this.dateEnvoi,
    this.lu = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      idMessage: json['idMessage'] as int?,
      idConversation: json['idConversation'] as int,
      expediteur: json['expediteur'] ?? '',
      destinataire: json['destinataire'] ?? '',
      contenu: json['contenu'] ?? '',
      dateEnvoi: json['dateEnvoi'] != null ? DateTime.tryParse(json['dateEnvoi']) : null,
      lu: json['lu'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'idConversation': idConversation,
    'expediteur': expediteur,
    'destinataire': destinataire,
    'contenu': contenu,
  };
}
