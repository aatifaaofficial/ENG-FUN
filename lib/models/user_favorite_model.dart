class UserFavoriteModel {
  final String id;
  final String userId;
  final String vocabularyId;
  final DateTime createdAt;

  UserFavoriteModel({
    required this.id,
    required this.userId,
    required this.vocabularyId,
    required this.createdAt,
  });

  factory UserFavoriteModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return UserFavoriteModel(
      id: json['id']?.toString() ?? '',
      // ✅ Use snake_case from database
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      vocabularyId: json['vocabulary_id']?.toString() ??
          json['vocabularyId']?.toString() ??
          '',
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId, // ✅ snake_case for database
        'vocabulary_id': vocabularyId, // ✅ snake_case for database
        'created_at': createdAt.toIso8601String(), // ✅ snake_case
      };
}
