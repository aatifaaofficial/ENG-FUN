class UserProgressModel {
  final String id;
  final String userId;
  final String vocabularyId;
  final int attempts;
  final int correct;
  final bool mastered;
  final DateTime lastAttempt;

  UserProgressModel({
    required this.id,
    required this.userId,
    required this.vocabularyId,
    required this.attempts,
    required this.correct,
    required this.mastered,
    required this.lastAttempt,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return UserProgressModel(
      id: json['id']?.toString() ?? '',
      // ✅ Use snake_case from database
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      vocabularyId: json['vocabulary_id']?.toString() ??
          json['vocabularyId']?.toString() ??
          '',
      attempts: json['attempts'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      mastered: json['mastered'] as bool? ?? false,
      lastAttempt: parseDateTime(json['last_attempt'] ?? json['lastAttempt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId, // ✅ snake_case for database
        'vocabulary_id': vocabularyId, // ✅ snake_case for database
        'attempts': attempts,
        'correct': correct,
        'mastered': mastered,
        'last_attempt': lastAttempt.toIso8601String(), // ✅ snake_case
      };
}
