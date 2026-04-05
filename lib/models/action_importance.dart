class ActionImportance {
  final int? id;
  final String label;
  final int points;
  final String? createdAt;
  final String? updateAt;

  ActionImportance({
    this.id,
    required this.label,
    required this.points,
    this.createdAt,
    this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'points': points,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory ActionImportance.fromMap(Map<String, dynamic> map) {
    return ActionImportance(
      id: map['id'] as int?,
      label: map['label'] as String,
      points: map['points'] as int,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
    );
  }
}
