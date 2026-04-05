class ActionNotification {
  final int? id;
  final int? actionId;
  final String title;
  final String? message;
  final int notificationType; // 1=motivation, 2=reminder, 3=success, 4=failure

  ActionNotification({
    this.id,
    this.actionId,
    required this.title,
    this.message,
    required this.notificationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_id': actionId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
    };
  }

  factory ActionNotification.fromMap(Map<String, dynamic> map) {
    return ActionNotification(
      id: map['id'] as int?,
      actionId: map['action_id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String?,
      notificationType: map['notification_type'] as int,
    );
  }

  String get typeLabel {
    switch (notificationType) {
      case 1:
        return 'Motivation';
      case 2:
        return 'Rappel';
      case 3:
        return 'Succès';
      case 4:
        return 'Échec';
      default:
        return 'Autre';
    }
  }
}
