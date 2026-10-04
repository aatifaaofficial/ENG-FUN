import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/data/vocabulary_data.dart';
import 'package:englishfun/models/vocabulary_model.dart';

class VocabularyState {
  const VocabularyState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.items = const [],
  });

  final String searchQuery;
  final String selectedCategory;
  final List<VocabularyWord> items;

  List<VocabularyWord> get filteredWords {
    final lowerQuery = searchQuery.toLowerCase();
    return items.where((word) {
      final matchesCategory = selectedCategory == 'All' || word.category == selectedCategory;
      final matchesQuery = lowerQuery.isEmpty ||
          word.word.toLowerCase().contains(lowerQuery) ||
          word.meaning.toLowerCase().contains(lowerQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  VocabularyState copyWith({
    String? searchQuery,
    String? selectedCategory,
    List<VocabularyWord>? items,
  }) {
    return VocabularyState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      items: items ?? this.items,
    );
  }
}

class VocabularyNotifier extends StateNotifier<VocabularyState> {
  VocabularyNotifier() : super(VocabularyState(items: vocabularyWords));

  void updateSearch(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(selectedCategory: value);
  }

  void toggleFavorite(int id) {
    final updated = state.items.map((word) {
      if (word.id == id) {
        return word.copyWith(isFavorite: !word.isFavorite);
      }
      return word;
    }).toList();
    state = state.copyWith(items: updated);
  }
}

final vocabularyProvider = StateNotifierProvider<VocabularyNotifier, VocabularyState>(
  (ref) => VocabularyNotifier(),
);
