class InAppNotification {
  final int? id;
  final String userId;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final String? idCible;
  final DateTime? createdAt;

  InAppNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.idCible,
    this.createdAt,
  });

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'],
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['read'] ?? json['isRead'] ?? false,
      idCible: json['idCible'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      if (isRead) 'read': isRead,
      if (idCible != null) 'idCible': idCible,
    };
  }
}
