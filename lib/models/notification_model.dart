class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? relatedId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedId: json['relatedId'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}