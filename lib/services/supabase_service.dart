// lib/services/supabase_service.dart
// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/models/vocabulary_model.dart';
import 'package:englishfun/models/practice_model.dart';
import 'package:englishfun/models/daily_streak_model.dart';
import 'package:englishfun/models/user_progress_model.dart';
import 'package:englishfun/models/user_favorite_model.dart';
import 'package:englishfun/models/practice_attempt_model.dart';
import 'package:englishfun/models/quiz_result_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late SupabaseClient client;

  static const String supabaseUrl = "https://unnigtdgawmivdhqnnlw.supabase.co";
  static const String supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVubmlndGRnYXdtaXZkaHFubmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjUxNDEsImV4cCI6MjA5MjcwMTE0MX0.VLGh_n7sGRUelYvBGJoxwi9r2bXIlXCSrBGnifOY5Go";

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    client = Supabase.instance.client;
  }

  // ========== AUTHENTICATION ==========

  // lib/services/supabase_service.dart (only signUp method changed)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔵 Attempting sign-up for email: $email');
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      print('🔵 Sign-up response received: ${response.user?.id ?? 'null'}');

      if (response.user != null) {
        final formattedName =
            name.isNotEmpty ? name : _formatNameFromEmail(email);
        await client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': formattedName,
          'avatar': '👤',
          'total_words_learned': 0,
          'daily_streak': 0,
          'accuracy': 0.0,
          'total_xp': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await client.from('daily_streaks').insert({
          'user_id': response.user!.id,
          'streak_count': 0,
          'last_practice_date': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ User profile and daily streak created successfully.');
      } else {
        print(
            '⚠️ Sign-up response user is null. Check email confirmation settings.');
      }
      return response;
    } catch (e) {
      print('❌ Sign-up error: $e');
      rethrow;
    }
  }
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _ensureUserProfile(response.user!.id, email);
        await client
            .from('users')
            .update({'updated_at': DateTime.now().toIso8601String()}).eq(
                'id', response.user!.id);
      }
      return response;
    } catch (e) {
      print('Sign in failed: $e');
      rethrow;
    }
  }

  /// Ensures a user row exists; creates one with a formatted name if missing.
  Future<void> _ensureUserProfile(String userId, String email) async {
    try {
      final existing = await getUserProfile(userId);
      if (existing == null) {
        final formattedName = _formatNameFromEmail(email);
        print(
          'Creating missing profile for user: $userId with name: $formattedName',
        );
        await client.from('users').insert({
          'id': userId,
          'email': email,
          'name': formattedName,
          'avatar': '👤',
          'total_words_learned': 0,
          'daily_streak': 0,
          'accuracy': 0.0,
          'total_xp': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await client.from('daily_streaks').insert({
          'user_id': userId,
          'streak_count': 0,
          'last_practice_date': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }

  /// Helper to format email local part into a readable name
  String _formatNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final parts = localPart.split(RegExp(r'[._\-]'));
    final formatted =
        parts.map((p) => p.trim()).where((p) => p.isNotEmpty).join(' ');
    return formatted
        .split(' ')
        .map(
          (w) => w.isNotEmpty
              ? w[0].toUpperCase() + w.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  User? getCurrentUser() => client.auth.currentUser;
  bool isAuthenticated() => client.auth.currentUser != null;

  // ========== USER PROFILE ==========

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('users').select().eq('id', userId).maybeSingle();
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? avatar,
    int? totalWordsLearned,
    int? dailyStreak,
    double? accuracy,
    int? totalXP,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) {
        updates['name'] = name;
      }
      if (avatar != null) {
        updates['avatar'] = avatar;
      }
      if (totalWordsLearned != null) {
        updates['total_words_learned'] = totalWordsLearned;
      }
      if (dailyStreak != null) {
        updates['daily_streak'] = dailyStreak;
      }
      if (accuracy != null) {
        updates['accuracy'] = accuracy;
      }
      if (totalXP != null) {
        updates['total_xp'] = totalXP;
      }

      await client.from('users').update(updates).eq('id', userId);
    } catch (e) {
      print('Failed to update user profile: $e');
    }
  }

  // ========== VOCABULARY ==========

  Future<List<VocabularyModel>> getAllVocabulary({String? level}) async {
    try {
      var query = client.from('vocabulary').select();
      if (level != null) query = query.eq('level', level);
      final response = await query;
      return (response as List)
          .map((item) => VocabularyModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch vocabulary: $e');
      return [];
    }
  }

  Future<VocabularyModel?> getVocabularyById(String vocabularyId) async {
    try {
      final response = await client
          .from('vocabulary')
          .select()
          .eq('id', vocabularyId)
          .maybeSingle();
      if (response == null) return null;
      return VocabularyModel.fromJson(response);
    } catch (e) {
      print('Failed to fetch vocabulary: $e');
      return null;
    }
  }

  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    try {
      final response =
          await client.from('vocabulary').select().ilike('word', '%$query%');
      return (response as List)
          .map((item) => VocabularyModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to search vocabulary: $e');
      return [];
    }
  }

  // ========== PRACTICE QUESTIONS ==========

  Future<List<PracticeQuestion>> getPracticeQuestions({
    String? type,
    String? level,
  }) async {
    try {
      var query = client.from('practice_questions').select();
      if (type != null) query = query.eq('type', type);
      if (level != null) query = query.eq('level', level);
      final response = await query;
      return (response as List)
          .map((item) => PracticeQuestion.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch practice questions: $e');
      return [];
    }
  }

  Future<PracticeQuestion?> getPracticeQuestionById(String questionId) async {
    try {
      final response = await client
          .from('practice_questions')
          .select()
          .eq('id', questionId)
          .maybeSingle();
      if (response == null) return null;
      return PracticeQuestion.fromJson(response);
    } catch (e) {
      print('Failed to fetch practice question: $e');
      return null;
    }
  }

  // ========== DAILY STREAKS ==========

  Future<DailyStreakModel?> getDailyStreak(String userId) async {
    try {
      final response = await client
          .from('daily_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) return null;
      return DailyStreakModel.fromJson(response);
    } catch (e) {
      print('Failed to fetch daily streak: $e');
      return null;
    }
  }

  Future<void> updateDailyStreak({
    required String userId,
    required int streakCount,
    required DateTime lastPracticeDate,
  }) async {
    try {
      await client.from('daily_streaks').update({
        'streak_count': streakCount,
        'last_practice_date': lastPracticeDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      print('Failed to update daily streak: $e');
    }
  }

  // ========== USER PROGRESS ==========

  Future<UserProgressModel?> getUserProgress({
    required String userId,
    required String vocabularyId,
  }) async {
    try {
      final response = await client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('vocabulary_id', vocabularyId)
          .maybeSingle();
      if (response == null) return null;
      return UserProgressModel.fromJson(response);
    } catch (e) {
      print('Failed to fetch user progress: $e');
      return null;
    }
  }

  Future<List<UserProgressModel>> getUserAllProgress(String userId) async {
    try {
      final response =
          await client.from('user_progress').select().eq('user_id', userId);
      return (response as List)
          .map((item) => UserProgressModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch user all progress: $e');
      return [];
    }
  }

  Future<void> updateUserProgress({
    required String userId,
    required String vocabularyId,
    required int attempts,
    required int correct,
    required bool mastered,
  }) async {
    try {
      final existing = await getUserProgress(
        userId: userId,
        vocabularyId: vocabularyId,
      );
      if (existing != null) {
        await client
            .from('user_progress')
            .update({
              'attempts': existing.attempts + attempts,
              'correct': existing.correct + correct,
              'mastered': mastered,
              'last_attempt': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('vocabulary_id', vocabularyId);
      } else {
        await client.from('user_progress').insert({
          'id':
              '${userId}_${vocabularyId}_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': userId,
          'vocabulary_id': vocabularyId,
          'attempts': attempts,
          'correct': correct,
          'mastered': mastered,
          'last_attempt': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Failed to update user progress: $e');
    }
  }

  // ========== USER FAVORITES ==========

  Future<List<UserFavoriteModel>> getUserFavorites(String userId) async {
    try {
      final response =
          await client.from('user_favorites').select().eq('user_id', userId);
      return (response as List)
          .map((item) => UserFavoriteModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch favorites: $e');
      return [];
    }
  }

  Future<void> addToFavorites({
    required String userId,
    required String vocabularyId,
  }) async {
    try {
      await client.from('user_favorites').insert({
        'id':
            '${userId}_${vocabularyId}_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'vocabulary_id': vocabularyId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites({
    required String userId,
    required String vocabularyId,
  }) async {
    try {
      await client
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('vocabulary_id', vocabularyId);
    } catch (e) {
      print('Failed to remove from favorites: $e');
    }
  }

  // ========== PRACTICE ATTEMPTS ==========

  Future<List<PracticeAttemptModel>> getPracticeAttempts({
    required String userId,
    String? questionId,
  }) async {
    try {
      var query =
          client.from('practice_attempts').select().eq('user_id', userId);
      if (questionId != null) query = query.eq('question_id', questionId);
      final response = await query;
      return (response as List)
          .map((item) => PracticeAttemptModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch practice attempts: $e');
      return [];
    }
  }

  Future<void> recordPracticeAttempt({
    required String userId,
    required String questionId,
    required String userAnswer,
    required bool isCorrect,
    required int xpGained,
  }) async {
    try {
      await client.from('practice_attempts').insert({
        'id':
            '${userId}_${questionId}_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'xp_gained': xpGained,
        'attempted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to record practice attempt: $e');
    }
  }

  // ========== QUIZ RESULTS ==========

  Future<List<QuizResultModel>> getUserQuizResults(String userId) async {
    try {
      final response =
          await client.from('quiz_results').select().eq('user_id', userId);
      return (response as List)
          .map((item) => QuizResultModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Failed to fetch quiz results: $e');
      return [];
    }
  }

  Future<void> recordQuizResult({
    required String userId,
    required int score,
    required int totalQuestions,
    required double accuracy,
  }) async {
    try {
      await client.from('quiz_results').insert({
        'id': '${userId}_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'score': score,
        'total_questions': totalQuestions,
        'accuracy': accuracy,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to record quiz result: $e');
    }
  }
}
