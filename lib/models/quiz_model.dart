class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.xpReward,
  });

  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int xpReward;
}
