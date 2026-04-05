class AppUser {
  final int? id;
  final int? disciplineBadgeId;
  final int totalScore;
  final String mail;
  final String firstname;
  final String lastname;
  final String gender;
  final String birthDate;
  final int currentDisciplineStreak;
  final int maxDisciplineStreak;
  final String? createdAt;
  final String? updateAt;

  AppUser({
    this.id,
    this.disciplineBadgeId,
    this.totalScore = 0,
    required this.mail,
    required this.firstname,
    required this.lastname,
    required this.gender,
    required this.birthDate,
    this.currentDisciplineStreak = 0,
    this.maxDisciplineStreak = 0,
    this.createdAt,
    this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discipline_badge_id': disciplineBadgeId,
      'total_score': totalScore,
      'mail': mail,
      'firstname': firstname,
      'lastname': lastname,
      'gender': gender,
      'birth_date': birthDate,
      'current_discipline_streak': currentDisciplineStreak,
      'max_discipline_streak': maxDisciplineStreak,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      disciplineBadgeId: map['discipline_badge_id'] as int?,
      totalScore: map['total_score'] as int? ?? 0,
      mail: map['mail'] as String,
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      gender: map['gender'] as String,
      birthDate: map['birth_date'] as String,
      currentDisciplineStreak: map['current_discipline_streak'] as int? ?? 0,
      maxDisciplineStreak: map['max_discipline_streak'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
    );
  }

  AppUser copyWith({
    int? id,
    int? disciplineBadgeId,
    int? totalScore,
    String? mail,
    String? firstname,
    String? lastname,
    String? gender,
    String? birthDate,
    int? currentDisciplineStreak,
    int? maxDisciplineStreak,
  }) {
    return AppUser(
      id: id ?? this.id,
      disciplineBadgeId: disciplineBadgeId ?? this.disciplineBadgeId,
      totalScore: totalScore ?? this.totalScore,
      mail: mail ?? this.mail,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      currentDisciplineStreak: currentDisciplineStreak ?? this.currentDisciplineStreak,
      maxDisciplineStreak: maxDisciplineStreak ?? this.maxDisciplineStreak,
      createdAt: createdAt,
      updateAt: updateAt,
    );
  }

  String get disciplineLevel {
    if (currentDisciplineStreak >= 90) return 'Exemplaire';
    if (currentDisciplineStreak >= 30) return 'Discipliné';
    if (currentDisciplineStreak >= 7) return 'Régulier';
    return 'Débutant';
  }
}
