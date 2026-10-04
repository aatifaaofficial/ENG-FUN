// ignore_for_file: use_super_parameters, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/navigation/app_router.dart';
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/core/theme/theme_provider.dart';
import 'package:englishfun/services/auth_provider.dart';

class FlashcardsScreen extends FlashcardScreen {
  const FlashcardsScreen({super.key});
}

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  List<bool> _isFlipped = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocab = ref.watch(vocabularyProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: vocab.when(
        data: (vocabList) {
          if (vocabList.isEmpty) {
            return Center(child: Text('No vocabulary available'));
          }

          if (_isFlipped.length != vocabList.length) {
            _isFlipped = List.filled(vocabList.length, false);
          }

          return _buildFlashcardContent(context, vocabList);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, st) {
          print('Error: $err');
          return Center(child: Text('Error loading vocabulary'));
        },
      ),
    );
  }

  Widget _buildFlashcardContent(BuildContext context, vocabList) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      children: [
        // Progress
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${vocabList.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / vocabList.length,
                minHeight: 8,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),

        // Flashcards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: vocabList.length,
            itemBuilder: (context, index) {
              final vocab = vocabList[index];
              return FlashcardWidget(
                word: vocab.word,
                meaning: vocab.meaning,
                bangla: vocab.bangla, // ✅ correct field name
                isFlipped: _isFlipped[index],
                onFlip: () {
                  setState(() {
                    _isFlipped[index] = !_isFlipped[index];
                  });
                },
              );
            },
          ),
        ),

        // Navigation Buttons – theme‑aware
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: Icon(Icons.arrow_back),
                label: Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _currentIndex < vocabList.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: Icon(Icons.arrow_forward),
                label: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  final String word;
  final String meaning;
  final String? bangla;
  final bool isFlipped;
  final VoidCallback onFlip;

  const FlashcardWidget({
    Key? key,
    required this.word,
    required this.meaning,
    this.bangla,
    required this.isFlipped,
    required this.onFlip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: GestureDetector(
          onTap: onFlip,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Card(
              key: ValueKey(isFlipped),
              color: isFlipped
                  ? (isDark
                      ? Colors.amber[700]
                      : Colors.amber[300]) // flipped colour adapts
                  : Theme.of(context).colorScheme.primary, // front uses primary
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isFlipped) ...[
                      const Text(
                        'Tap to reveal',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        word,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        meaning,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (bangla != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          '($bangla)',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]
                    ],
                    const SizedBox(height: 32),
                    Text(
                      'Tap to flip',
                      style: TextStyle(
                        color: isFlipped
                            ? (isDark ? Colors.white70 : Colors.black54)
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
