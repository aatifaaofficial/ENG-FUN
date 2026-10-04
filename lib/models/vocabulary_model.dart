class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.example,
    required this.category,
    required this.difficulty,
    this.isFavorite = false,
  });

  final int id;
  final String word;
  final String pronunciation;
  final String meaning;
  final String example;
  final String category;
  final String difficulty;
  final bool isFavorite;

  String get partOfSpeech => 'Word';
  String get bangla => meaning;
  String get level => difficulty;
  List<String> get synonyms => const [];
  List<String> get examples => [example];

  VocabularyWord copyWith({
    int? id,
    String? word,
    String? pronunciation,
    String? meaning,
    String? example,
    String? category,
    String? difficulty,
    bool? isFavorite,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      word: word ?? this.word,
      pronunciation: pronunciation ?? this.pronunciation,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: ((json['id'] ?? 1) as num? ?? 1).toInt(),
      word: json['word']?.toString() ?? '',
      pronunciation: json['pronunciation']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      example: json['example']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Basic',
      difficulty: json['difficulty']?.toString() ?? json['level']?.toString() ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'example': example,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

typedef VocabularyModel = VocabularyWord;
