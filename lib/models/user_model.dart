class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.totalXp = 0,
    this.streak = 0,
    this.wordsLearned = 0,
    this.quizzesCompleted = 0,
    this.averageAccuracy = 0.0,
    this.avatar = '',
  });

  final String name;
  final String email;
  final int totalXp;
  final int streak;
  final int wordsLearned;
  final int quizzesCompleted;
  final double averageAccuracy;
  final String avatar;

  int get dailyStreak => streak;
  int get totalWordsLearned => wordsLearned;
  int get totalXP => totalXp;
  double get accuracy => averageAccuracy;

  factory UserProfile.empty() => const UserProfile(name: 'English Learner', email: '');

  UserProfile copyWith({
    String? name,
    String? email,
    int? totalXp,
    int? streak,
    int? wordsLearned,
    int? quizzesCompleted,
    double? averageAccuracy,
    String? avatar,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'totalXp': totalXp,
      'streak': streak,
      'wordsLearned': wordsLearned,
      'quizzesCompleted': quizzesCompleted,
      'averageAccuracy': averageAccuracy,
      'avatar': avatar,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final totalXp = (json['totalXp'] ?? json['total_xp'] ?? json['totalXP'] ?? 0) as num? ?? 0;
    final streak = (json['streak'] ?? json['daily_streak'] ?? json['dailyStreak'] ?? 0) as num? ?? 0;
    final wordsLearned = (json['wordsLearned'] ?? json['total_words_learned'] ?? json['totalWordsLearned'] ?? 0) as num? ?? 0;
    final quizCount = (json['quizzesCompleted'] ?? json['total_quizzes'] ?? json['quizzes_completed'] ?? 0) as num? ?? 0;
    final accuracy = (json['averageAccuracy'] ?? json['accuracy'] ?? 0.0) as num? ?? 0.0;

    return UserProfile(
      name: json['name'] as String? ?? 'English Learner',
      email: json['email'] as String? ?? '',
      totalXp: totalXp.toInt(),
      streak: streak.toInt(),
      wordsLearned: wordsLearned.toInt(),
      quizzesCompleted: quizCount.toInt(),
      averageAccuracy: accuracy.toDouble(),
      avatar: json['avatar'] as String? ?? '',
    );
  }
}

typedef UserModel = UserProfile;
