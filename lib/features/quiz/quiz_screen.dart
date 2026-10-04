// ignore_for_file: use_super_parameters, prefer_const_constructors, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/navigation/app_router.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/constants/app_constants.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  Future<void> _submitFinalQuizMetrics(int totalQuestions) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final double sessionAccuracy = (_score / totalQuestions) * 100;
    final int earnedXP = _score * 15;

    try {
      // ✅ Use 'users' table, correct columns: total_xp, accuracy
      final profile = await _supabase
          .from('users')
          .select('total_xp, accuracy')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        print('No profile found for user $userId');
        // Still show completion, but don't update DB
        if (mounted) _showQuizCompletion(totalQuestions, earnedXP);
        return;
      }

      final int currentXP = profile['total_xp'] ?? 0;
      final double currentAccuracy =
          (profile['accuracy'] as num?)?.toDouble() ?? 0.0;

      final double finalAccuracy = currentAccuracy == 0.0
          ? sessionAccuracy
          : (currentAccuracy + sessionAccuracy) / 2;

      await _supabase.from('users').update({
        'total_xp': currentXP + earnedXP,
        'accuracy': finalAccuracy,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) _showQuizCompletion(totalQuestions, earnedXP);
    } catch (e) {
      print('Database Update Error: $e');
      if (mounted) _showQuizCompletion(totalQuestions, earnedXP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // ✅ Use correct column: 'level' instead of 'difficulty_level'
        stream: _supabase
            .from('practice_questions')
            .stream(primaryKey: ['id']).eq('level', 'Advanced'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            print('Error fetching quiz: ${snapshot.error}');
            return const Center(
                child: Text('No advanced quiz questions available.'));
          }

          final questionList = snapshot.data!;
          // Ensure index is within range
          if (_currentQuestionIndex >= questionList.length) {
            _currentQuestionIndex = 0;
          }
          final currentQuestion = questionList[_currentQuestionIndex];
          final progress = (_currentQuestionIndex + 1) / questionList.length;

          return _buildQuizContent(
              context, currentQuestion, progress, questionList.length);
        },
      ),
    );
  }

  Widget _buildQuizContent(
      BuildContext context,
      Map<String, dynamic> currentQuestion,
      double progress,
      int totalQuestions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentQuestionIndex + 1}/$totalQuestions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
            valueColor:
                AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 32),
          CustomCard(
            // Use theme-aware background
            backgroundColor:
                isDark ? Colors.grey[850] : const Color(0xFFF5F7FA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // ✅ Use 'question' column
                  currentQuestion['question'] ?? 'Question Missing',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                _buildQuestionOptions(currentQuestion),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _selectedAnswer == null
                ? null
                : _answered
                    ? () {
                        if (_currentQuestionIndex < totalQuestions - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        } else {
                          _submitFinalQuizMetrics(totalQuestions);
                        }
                      }
                    : () {
                        setState(() => _answered = true);
                        final isCorrect = _selectedAnswer ==
                            currentQuestion['correct_answer'];
                        if (isCorrect) setState(() => _score++);
                      },
            icon: Icon(_answered ? Icons.arrow_forward : Icons.check),
            label: Text(_answered
                ? (_currentQuestionIndex == totalQuestions - 1
                    ? 'Finish'
                    : 'Next')
                : 'Submit Answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionOptions(Map<String, dynamic> currentQuestion) {
    final options = currentQuestion['options'] as List<dynamic>? ?? [];
    final correctAnswer = currentQuestion['correct_answer'] ?? '';

    return Column(
      children: options.map((option) {
        final optionStr = option.toString();
        final isSelected = _selectedAnswer == optionStr;
        final isCorrect = optionStr == correctAnswer;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: _answered
                ? null
                : () => setState(() => _selectedAnswer = optionStr),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (_answered && isCorrect
                        ? Colors.green[100]
                        : _answered && !isCorrect
                            ? Colors.red[100]
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1))
                    : (_answered && isCorrect
                        ? Colors.green[100]
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100]),
                border: Border.all(
                  color: isSelected
                      ? (_answered && isCorrect
                          ? Colors.green
                          : _answered && !isCorrect
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary)
                      : (_answered && isCorrect
                          ? Colors.green
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey[300]!),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionStr,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_answered && isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (_answered && isSelected && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showQuizCompletion(int totalQuestions, int earnedXP) {
    final accuracy = (_score / totalQuestions * 100).toStringAsFixed(0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete! 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score: $_score/$totalQuestions',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: $accuracy%',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Chip(
              backgroundColor: Colors.amber[100],
              label: Text(
                '🔥 +$earnedXP XP Rewards Added!',
                style: const TextStyle(
                    color: Colors.brown, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRouter.home);
              },
              child: const Text('Back to Home', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
