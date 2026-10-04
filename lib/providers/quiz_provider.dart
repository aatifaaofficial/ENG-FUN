import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/data/quiz_data.dart';
import 'package:englishfun/models/quiz_model.dart';

class QuizSessionState {
  const QuizSessionState({
    this.currentIndex = 0,
    this.correctAnswers = 0,
    this.xpEarned = 0,
    this.isComplete = false,
    this.questions = const [],
    this.selectedAnswer,
    this.showFeedback = false,
  });

  final int currentIndex;
  final int correctAnswers;
  final int xpEarned;
  final bool isComplete;
  final List<QuizQuestion> questions;
  final String? selectedAnswer;
  final bool showFeedback;

  int get totalQuestions => questions.length;
  double get accuracy => totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;
  QuizQuestion? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length ? null : questions[currentIndex];

  QuizSessionState copyWith({
    int? currentIndex,
    int? correctAnswers,
    int? xpEarned,
    bool? isComplete,
    List<QuizQuestion>? questions,
    String? selectedAnswer,
    bool? showFeedback,
  }) {
    return QuizSessionState(
      currentIndex: currentIndex ?? this.currentIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpEarned: xpEarned ?? this.xpEarned,
      isComplete: isComplete ?? this.isComplete,
      questions: questions ?? this.questions,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      showFeedback: showFeedback ?? this.showFeedback,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizSessionState> {
  QuizNotifier() : super(QuizSessionState(questions: quizQuestions));

  void submitAnswer(String answer) {
    if (state.currentQuestion == null || state.isComplete) {
      return;
    }

    final currentQuestion = state.currentQuestion!;
    final isCorrect = answer == currentQuestion.correctAnswer;
    final nextCorrect = state.correctAnswers + (isCorrect ? 1 : 0);
    final nextXp = state.xpEarned + (isCorrect ? currentQuestion.xpReward : 0);

    if (state.currentIndex >= state.totalQuestions - 1) {
      state = state.copyWith(
        correctAnswers: nextCorrect,
        xpEarned: nextXp,
        isComplete: true,
        selectedAnswer: answer,
        showFeedback: true,
      );
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      correctAnswers: nextCorrect,
      xpEarned: nextXp,
      selectedAnswer: answer,
      showFeedback: true,
    );
  }

  void reset() {
    state = QuizSessionState(questions: quizQuestions);
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizSessionState>(
  (ref) => QuizNotifier(),
);
