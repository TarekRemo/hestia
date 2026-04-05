class ActionHistory {
  final int? id;
  final int? actionId;
  final String date;
  final int actionStatus; // -1=unknown, 0=not done, 1=done
  final String? userComment;
  final String? createdAt;
  final String? updateAt;

  // Joined fields
  final String? actionName;
  final bool? actionIsPositive;
  final int? importancePoints;

  ActionHistory({
    this.id,
    this.actionId,
    required this.date,
    this.actionStatus = -1,
    this.userComment,
    this.createdAt,
    this.updateAt,
    this.actionName,
    this.actionIsPositive,
    this.importancePoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_id': actionId,
      'date': date,
      'action_status': actionStatus,
      'user_comment': userComment,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory ActionHistory.fromMap(Map<String, dynamic> map) {
    return ActionHistory(
      id: map['id'] as int?,
      actionId: map['action_id'] as int?,
      date: map['date'] as String,
      actionStatus: map['action_status'] as int? ?? -1,
      userComment: map['user_comment'] as String?,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
      actionName: map['action_name'] as String?,
      actionIsPositive: map['is_positive'] != null ? (map['is_positive'] as int) == 1 : null,
      importancePoints: map['importance_points'] as int?,
    );
  }

  String get statusLabel {
    switch (actionStatus) {
      case 1:
        return 'Réalisé';
      case 0:
        return 'Non réalisé';
      default:
        return 'Inconnu';
    }
  }

  int get scoreImpact {
    final pts = importancePoints ?? 10;
    final positive = actionIsPositive ?? true;
    if (actionStatus == 1) {
      return positive ? pts : -pts;
    } else if (actionStatus == 0) {
      return positive ? -pts : pts;
    }
    return 0;
  }
}
