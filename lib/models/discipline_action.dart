class DisciplineAction {
  final int? id;
  final int? userId;
  final int? actionImportanceId;
  final String name;
  final String? description;
  final int? frequency; // 1=quotidienne, 7=hebdomadaire, custom
  final bool isPositive;
  final int currentStreak;
  final int recordStreak;
  final String? createdAt;
  final String? updateAt;

  // Joined fields
  final String? importanceLabel;
  final int? importancePoints;

  DisciplineAction({
    this.id,
    this.userId,
    this.actionImportanceId,
    required this.name,
    this.description,
    this.frequency,
    this.isPositive = true,
    this.currentStreak = 0,
    this.recordStreak = 0,
    this.createdAt,
    this.updateAt,
    this.importanceLabel,
    this.importancePoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action_importance_id': actionImportanceId,
      'name': name,
      'description': description,
      'frequency': frequency,
      'is_positive': isPositive ? 1 : 0,
      'current_streak': currentStreak,
      'record_streak': recordStreak,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory DisciplineAction.fromMap(Map<String, dynamic> map) {
    return DisciplineAction(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      actionImportanceId: map['action_importance_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      frequency: map['frequency'] as int?,
      isPositive: (map['is_positive'] as int?) == 1,
      currentStreak: map['current_streak'] as int? ?? 0,
      recordStreak: map['record_streak'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
      importanceLabel: map['importance_label'] as String?,
      importancePoints: map['importance_points'] as int?,
    );
  }

  DisciplineAction copyWith({
    int? id,
    int? userId,
    int? actionImportanceId,
    String? name,
    String? description,
    int? frequency,
    bool? isPositive,
    int? currentStreak,
    int? recordStreak,
  }) {
    return DisciplineAction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actionImportanceId: actionImportanceId ?? this.actionImportanceId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      isPositive: isPositive ?? this.isPositive,
      currentStreak: currentStreak ?? this.currentStreak,
      recordStreak: recordStreak ?? this.recordStreak,
      createdAt: createdAt,
      updateAt: updateAt,
      importanceLabel: importanceLabel,
      importancePoints: importancePoints,
    );
  }

  String get frequencyLabel {
    if (frequency == null) return 'Non définie';
    if (frequency == 1) return 'Quotidienne';
    if (frequency == 7) return 'Hebdomadaire';
    return 'Tous les $frequency jours';
  }

  int get pointsOnDone {
    final pts = importancePoints ?? 10;
    return isPositive ? pts : -pts;
  }

  int get pointsOnNotDone {
    final pts = importancePoints ?? 10;
    return isPositive ? -pts : pts;
  }
}
