import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/data/flashcard_data.dart';
import 'package:englishfun/models/flashcard_model.dart';

class FlashcardState {
  const FlashcardState({
    this.currentIndex = 0,
    this.isFront = true,
    this.knownCount = 0,
    this.needsPracticeCount = 0,
  });

  final int currentIndex;
  final bool isFront;
  final int knownCount;
  final int needsPracticeCount;

  FlashcardItem get currentCard => flashcards[currentIndex];

  FlashcardState copyWith({
    int? currentIndex,
    bool? isFront,
    int? knownCount,
    int? needsPracticeCount,
  }) {
    return FlashcardState(
      currentIndex: currentIndex ?? this.currentIndex,
      isFront: isFront ?? this.isFront,
      knownCount: knownCount ?? this.knownCount,
      needsPracticeCount: needsPracticeCount ?? this.needsPracticeCount,
    );
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  FlashcardNotifier() : super(const FlashcardState());

  void toggleFlip() {
    state = state.copyWith(isFront: !state.isFront);
  }

  void nextCard() {
    final nextIndex = (state.currentIndex + 1) % flashcards.length;
    state = state.copyWith(currentIndex: nextIndex, isFront: true);
  }

  void previousCard() {
    final nextIndex = (state.currentIndex - 1 + flashcards.length) % flashcards.length;
    state = state.copyWith(currentIndex: nextIndex, isFront: true);
  }

  void markKnown() {
    state = state.copyWith(knownCount: state.knownCount + 1, isFront: true);
  }

  void markNeedsPractice() {
    state = state.copyWith(needsPracticeCount: state.needsPracticeCount + 1, isFront: true);
  }
}

final flashcardProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>(
  (ref) => FlashcardNotifier(),
);
