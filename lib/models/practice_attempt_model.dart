class PracticeAttemptModel {
  final String id;
  final String userId;
  final String questionId;
  final String userAnswer;
  final bool isCorrect;
  final int xpGained;
  final DateTime attemptedAt;

  PracticeAttemptModel({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.xpGained,
    required this.attemptedAt,
  });

  factory PracticeAttemptModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return PracticeAttemptModel(
      id: json['id']?.toString() ?? '',
      // ✅ Use snake_case from database
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      questionId: json['question_id']?.toString() ??
          json['questionId']?.toString() ??
          '',
      userAnswer: json['user_answer']?.toString() ??
          json['userAnswer']?.toString() ??
          '',
      isCorrect:
          json['is_correct'] as bool? ?? json['isCorrect'] as bool? ?? false,
      xpGained: json['xp_gained'] as int? ?? json['xpGained'] as int? ?? 0,
      attemptedAt: parseDateTime(json['attempted_at'] ?? json['attemptedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId, // ✅ snake_case for database
        'question_id': questionId, // ✅ snake_case for database
        'user_answer': userAnswer, // ✅ snake_case for database
        'is_correct': isCorrect, // ✅ snake_case for database
        'xp_gained': xpGained, // ✅ snake_case for database
        'attempted_at': attemptedAt.toIso8601String(), // ✅ snake_case
      };
}
