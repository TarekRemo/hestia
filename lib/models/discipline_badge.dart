class DisciplineBadge {
  final int? id;
  final String label;
  final int minStreak;
  final String? createdAt;
  final String? updateAt;

  DisciplineBadge({
    this.id,
    required this.label,
    required this.minStreak,
    this.createdAt,
    this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'min_streak': minStreak,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory DisciplineBadge.fromMap(Map<String, dynamic> map) {
    return DisciplineBadge(
      id: map['id'] as int?,
      label: map['label'] as String,
      minStreak: map['min_streak'] as int,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
    );
  }

  DisciplineBadge copyWith({
    int? id,
    String? label,
    int? minStreak,
  }) {
    return DisciplineBadge(
      id: id ?? this.id,
      label: label ?? this.label,
      minStreak: minStreak ?? this.minStreak,
      createdAt: createdAt,
      updateAt: updateAt,
    );
  }
}
