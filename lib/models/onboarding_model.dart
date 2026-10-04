class OnboardingPage {
  final int id;
  final String title;
  final String description;
  final String icon;

  OnboardingPage({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  // ✅ Factory method to create from JSON (if you store in database)
  factory OnboardingPage.fromJson(Map<String, dynamic> json) {
    return OnboardingPage(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📚',
    );
  }

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
      };
}

// ✅ Static onboarding data (if not using database)
class OnboardingData {
  static List<OnboardingPage> getPages() {
    return [
      OnboardingPage(
        id: 1,
        title: 'Welcome to English Fun!',
        description: 'Learn English vocabulary in a fun and interactive way.',
        icon: '📚',
      ),
      OnboardingPage(
        id: 2,
        title: 'Practice Daily',
        description: 'Improve your skills with daily practice and quizzes.',
        icon: '✏️',
      ),
      OnboardingPage(
        id: 3,
        title: 'Track Your Progress',
        description: 'Monitor your learning journey and earn achievements.',
        icon: '📈',
      ),
      OnboardingPage(
        id: 4,
        title: 'Get Started',
        description: 'Let\'s begin your English learning adventure today!',
        icon: '🚀',
      ),
    ];
  }
}
