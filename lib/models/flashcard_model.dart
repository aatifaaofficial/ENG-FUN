class FlashcardItem {
  const FlashcardItem({
    required this.id,
    required this.front,
    required this.back,
    required this.example,
  });

  final int id;
  final String front;
  final String back;
  final String example;
}
