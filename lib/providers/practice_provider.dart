import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/data/practice_data.dart';
import 'package:englishfun/models/practice_model.dart';

class PracticeSessionState {
  const PracticeSessionState({
    this.currentIndex = 0,
    this.correctAnswers = 0,
    this.xpEarned = 0,
    this.isComplete = false,
    this.questions = const [],
  });

  final int currentIndex;
  final int correctAnswers;
  final int xpEarned;
  final bool isComplete;
  final List<PracticeQuestion> questions;

  int get totalQuestions => questions.length;
  double get accuracy => totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;
  PracticeQuestion? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length ? null : questions[currentIndex];

  PracticeSessionState copyWith({
    int? currentIndex,
    int? correctAnswers,
    int? xpEarned,
    bool? isComplete,
    List<PracticeQuestion>? questions,
  }) {
    return PracticeSessionState(
      currentIndex: currentIndex ?? this.currentIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpEarned: xpEarned ?? this.xpEarned,
      isComplete: isComplete ?? this.isComplete,
      questions: questions ?? this.questions,
    );
  }
}

class PracticeNotifier extends StateNotifier<PracticeSessionState> {
  PracticeNotifier() : super(PracticeSessionState(questions: dailyPracticeQuestions));

  void submitAnswer(String selectedAnswer) {
    if (state.currentQuestion == null || state.isComplete) {
      return;
    }

    final currentQuestion = state.currentQuestion!;
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;
    final nextCorrect = state.correctAnswers + (isCorrect ? 1 : 0);
    final nextXp = state.xpEarned + (isCorrect ? currentQuestion.xpReward : 0);

    if (state.currentIndex >= state.totalQuestions - 1) {
      state = state.copyWith(
        correctAnswers: nextCorrect,
        xpEarned: nextXp,
        isComplete: true,
      );
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      correctAnswers: nextCorrect,
      xpEarned: nextXp,
    );
  }

  void reset() {
    state = PracticeSessionState(questions: dailyPracticeQuestions);
  }
}

final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeSessionState>(
  (ref) => PracticeNotifier(),
);
