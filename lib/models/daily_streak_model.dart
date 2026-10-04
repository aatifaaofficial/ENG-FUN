class DailyStreakModel {
  final String id;
  final String userId;
  final int streakCount;
  final DateTime lastPracticeDate;
  final DateTime createdAt;

  DailyStreakModel({
    required this.id,
    required this.userId,
    required this.streakCount,
    required this.lastPracticeDate,
    required this.createdAt,
  });

  factory DailyStreakModel.fromJson(Map<String, dynamic> json) {
    // Safe timestamp parser
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return DailyStreakModel(
      id: json['id']?.toString() ?? '',
      // ✅ Use snake_case from database
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      streakCount:
          json['streak_count'] as int? ?? json['streakCount'] as int? ?? 0,
      lastPracticeDate:
          parseDateTime(json['last_practice_date'] ?? json['lastPracticeDate']),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId, // ✅ snake_case for database
        'streak_count': streakCount, // ✅ snake_case for database
        'last_practice_date':
            lastPracticeDate.toIso8601String(), // ✅ snake_case
        'created_at': createdAt.toIso8601String(), // ✅ snake_case
      };
}
