// ignore_for_file: use_super_parameters, prefer_const_constructors, use_key_in_widget_constructors, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/navigation/app_router.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/theme/app_theme.dart';
import 'package:englishfun/core/constants/app_constants.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int _currentQuestionIndex = 0;
  List<String> _selectedAnswers = [];
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isInitialized = false;

  // 🎯 Update user progress after finishing the quiz
  Future<void> _updateUserProgress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Fetch current profile data from 'users' table
      final profile = await _supabase
          .from('users')
          .select('total_xp, total_words_learned, daily_streak')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        print('No profile found for user $userId');
        return;
      }

      final int currentXP = profile['total_xp'] ?? 0;
      final int currentWords = profile['total_words_learned'] ?? 0;
      final int currentStreak = profile['daily_streak'] ?? 0;

      // Increment XP by 10, words learned by 1, and daily streak by 1
      await _supabase.from('users').update({
        'total_xp': currentXP + 10,
        'total_words_learned': currentWords + 1,
        'daily_streak': currentStreak + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Also update the daily_streaks table if you have it
      await _supabase.from('daily_streaks').upsert({
        'user_id': userId,
        'streak_count': currentStreak + 1,
        'last_practice_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Quiz completed! +10 XP added.')),
        );
        context.go(AppRouter.home);
      }
    } catch (e) {
      print('Error updating progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating progress: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Practice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('practice_questions').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error loading questions: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load questions. Please try again.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No practice questions available.'),
            );
          }

          final questionList = snapshot.data!;

          // Initialize selected answers list once
          if (!_isInitialized) {
            _selectedAnswers = List.filled(questionList.length, '');
            _isInitialized = true;
          }

          // Ensure current index is valid
          if (_currentQuestionIndex >= questionList.length) {
            _currentQuestionIndex = 0;
          }

          final question = questionList[_currentQuestionIndex];
          final progress = (_currentQuestionIndex + 1) / questionList.length;

          return _buildPracticeContent(
            context,
            question,
            progress,
            questionList.length,
          );
        },
      ),
    );
  }

  Widget _buildPracticeContent(BuildContext context,
      Map<String, dynamic> question, double progress, int totalQuestions) {
    // Extract question data using correct column names
    final questionText = question['question'] ?? 'Question missing';
    final options = question['options'] as List<dynamic>? ?? [];
    final correctAnswer = question['correct_answer'] ?? '';
    final questionType = question['type'] ?? 'multiple_choice';

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
              Chip(
                label: Text(questionType.replaceAll('_', ' ').toUpperCase()),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            progress: progress,
            progressColor: AppColors.primary,
          ),
          const SizedBox(height: 32),

          // Question card
          CustomCard(
            backgroundColor: const Color(0xFFF5F7FA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                _buildAnswerOptions(questionType, options, correctAnswer),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Feedback message
          if (_showFeedback)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green[50] : Colors.red[50],
                border: Border.all(
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                _isCorrect
                    ? '✓ Correct!'
                    : '✗ Incorrect. Correct answer: $correctAnswer',
                style: TextStyle(
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentQuestionIndex < totalQuestions - 1) {
                      _nextQuestion();
                    } else {
                      _updateUserProgress(); // Submit and update progress
                    }
                  },
                  icon: Icon(_currentQuestionIndex == totalQuestions - 1
                      ? Icons.check
                      : Icons.arrow_forward),
                  label: Text(_currentQuestionIndex == totalQuestions - 1
                      ? 'Submit'
                      : 'Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(
      String type, List<dynamic> options, String correctAnswer) {
    if (type == 'true_false') {
      // For true/false, options are ["True", "False"]
      return Column(
        children: options.map((option) {
          final optionStr = option.toString();
          return _buildOptionTile(optionStr, correctAnswer);
        }).toList(),
      );
    } else if (type == 'fill_blank') {
      // For fill in the blank, options are possible answers
      return Column(
        children: options.map((option) {
          final optionStr = option.toString();
          return _buildOptionTile(optionStr, correctAnswer);
        }).toList(),
      );
    } else {
      // Default: multiple_choice
      return Column(
        children: options.map((option) {
          final optionStr = option.toString();
          return _buildOptionTile(optionStr, correctAnswer);
        }).toList(),
      );
    }
  }

  Widget _buildOptionTile(String optionStr, String correctAnswer) {
    final isSelected = _selectedAnswers[_currentQuestionIndex] == optionStr;
    final isCorrect = optionStr == correctAnswer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAnswers[_currentQuestionIndex] = optionStr;
            _isCorrect = isCorrect;
            _showFeedback = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _showFeedback && isCorrect
                ? Colors.green[100]
                : _showFeedback && isSelected && !isCorrect
                    ? Colors.red[100]
                    : isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[100],
            border: Border.all(
              color: _showFeedback && isCorrect
                  ? Colors.green
                  : _showFeedback && isSelected && !isCorrect
                      ? Colors.red
                      : isSelected
                          ? AppColors.primary
                          : Colors.grey[300]!,
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
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
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
              if (_showFeedback && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (_showFeedback && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _showFeedback = false;
        _currentQuestionIndex--;
        // Reset feedback based on current selection
        final selected = _selectedAnswers[_currentQuestionIndex];
        if (selected.isNotEmpty) {
          // We'll need to re-evaluate correctness, but we'll let the user click again.
          // For simplicity, we just hide feedback.
        }
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
      _currentQuestionIndex++;
    });
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color progressColor;

  const ProgressBar({
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation(progressColor),
      ),
    );
  }
}
