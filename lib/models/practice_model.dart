class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.type = 'multiple_choice',
    this.explanation,
    this.level,
    this.vocabularyId,
    this.xpReward = 10,
  });

  final int id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? level;
  final String? vocabularyId;
  final int xpReward;

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      id: ((json['id'] ?? 0) as num? ?? 0).toInt(),
      type: json['type']?.toString() ?? 'multiple_choice',
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer: json['correct_answer']?.toString() ??
          json['correctAnswer']?.toString() ??
          '',
      explanation: json['explanation']?.toString(),
      level: json['level']?.toString(),
      vocabularyId:
          json['vocabulary_id']?.toString() ?? json['vocabularyId']?.toString(),
      xpReward: ((json['xpReward'] ?? json['xp_reward'] ?? 10) as num? ?? 10).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'question': question,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'level': level,
        'vocabulary_id': vocabularyId,
        'xpReward': xpReward,
      };
}
