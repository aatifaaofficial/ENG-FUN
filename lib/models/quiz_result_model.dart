class QuizResultModel {
  final String id;
  final String userId;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final DateTime completedAt;

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.completedAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return QuizResultModel(
      id: json['id']?.toString() ?? '',
      // ✅ Use snake_case from database
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ??
          json['totalQuestions'] as int? ??
          0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      completedAt: parseDateTime(json['completed_at'] ?? json['completedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId, // ✅ snake_case for database
        'score': score,
        'total_questions': totalQuestions, // ✅ snake_case for database
        'accuracy': accuracy,
        'completed_at': completedAt.toIso8601String(), // ✅ snake_case
      };
}
