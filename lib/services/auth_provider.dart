// lib/services/auth_provider.dart
// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/services/supabase_service.dart';
import 'package:englishfun/providers/auth_provider.dart' as local_auth;
import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/models/vocabulary_model.dart';
import 'package:englishfun/models/practice_model.dart';
import 'package:englishfun/models/daily_streak_model.dart';
import 'package:englishfun/models/user_progress_model.dart';
import 'package:englishfun/models/user_favorite_model.dart';
import 'package:englishfun/models/practice_attempt_model.dart';
import 'package:englishfun/models/quiz_result_model.dart';

// ==========================================
// AUTHENTICATION STATES & STREAMS
// ==========================================

/// Streams real-time authentication state updates directly from Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = SupabaseService();
  return supabase.client.auth.onAuthStateChange;
});

/// Exposes the raw current user session metadata object.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final supabase = SupabaseService();
  return supabase.client.auth.currentUser;
});

/// Dynamically watches [authStateProvider] to instantly load, refresh,
/// or clear the logged-in user profile metrics from the database.
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  try {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) async {
        var sessionUser = authState.session?.user ??
            SupabaseService().client.auth.currentUser;

        if (sessionUser == null) {
          await Future.delayed(const Duration(milliseconds: 300));
          sessionUser = SupabaseService().client.auth.currentUser;
        }

        if (sessionUser == null) {
          return null;
        }

        return await SupabaseService().getUserProfile(sessionUser.id);
      },
      loading: () async {
        final runtimeUser = SupabaseService().client.auth.currentUser;
        if (runtimeUser != null) {
          return await SupabaseService().getUserProfile(runtimeUser.id);
        }
        return null;
      },
      error: (err, stack) {
        return null;
      },
    );
  } catch (e) {
    return null;
  }
});

// ==========================================
// AUTHENTICATION STATE NOTIFIER CONTROLLER
// ==========================================

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final SupabaseService _supabaseService = SupabaseService();

  AuthController(this.ref) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signUp(
          email: email, password: password, name: name);
      state = const AsyncValue.data(null);
      _invalidateProfilePipelines();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw StateError('Authentication returned no user.');
      }

      final profile = await _supabaseService.getUserProfile(user.id);
      await ref.read(local_auth.authProvider.notifier).login(
            profile ??
                UserProfile(
                  name: email.split('@').first,
                  email: email,
                ),
          );
      state = const AsyncValue.data(null);
      _invalidateProfilePipelines();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signOut();
      await ref.read(local_auth.authProvider.notifier).logout();
      state = const AsyncValue.data(null);
      _invalidateProfilePipelines();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatar,
    int? totalWordsLearned,
    int? dailyStreak,
    double? accuracy,
    int? totalXP,
  }) async {
    try {
      await _supabaseService.updateUserProfile(
        userId: userId,
        name: name,
        avatar: avatar,
        totalWordsLearned: totalWordsLearned,
        dailyStreak: dailyStreak,
        accuracy: accuracy,
        totalXP: totalXP,
      );
      ref.invalidate(userProfileProvider);
    } catch (e) {
      throw Exception('Failed to update profile changes: $e');
    }
  }

  void _invalidateProfilePipelines() {
    ref.invalidate(authStateProvider);
    ref.invalidate(currentUserProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(favoritesVocabularyProvider);
  }
}

// ==========================================
// CORE CONTENT & METRICS PROVIDERS
// ==========================================

final vocabularyProvider =
    FutureProvider.family<List<VocabularyModel>, String?>((ref, filter) async {
  final supabase = SupabaseService();

  // Filter by level
  if (filter != 'Favorites') {
    return await supabase.getAllVocabulary(level: filter);
  }

  // Handle Favorites filter - watches auth state and fetches favorites
  ref.watch(authStateProvider);
  final favoritesVocabAsync = ref.watch(favoritesVocabularyProvider);
  return favoritesVocabAsync.value ?? [];
});

// Favorites vocabulary provider - fetches favorites vocabulary based on current user
final favoritesVocabularyProvider =
    FutureProvider<List<VocabularyModel>>((ref) async {
  final supabase = SupabaseService();
  final sessionUser = supabase.client.auth.currentUser;
  if (sessionUser == null) return [];

  final userId = sessionUser.id;
  final favorites = await supabase.getUserFavorites(userId);
  if (favorites.isEmpty) return [];

  final vocabularyIds = favorites.map((f) => f.vocabularyId).toList();
  List<VocabularyModel> vocabList = [];
  for (final id in vocabularyIds) {
    final response = await supabase.client
        .from('vocabulary')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response != null) {
      vocabList.add(VocabularyModel.fromJson(response));
    }
  }
  return vocabList;
});

// Provider to manually trigger favorites refresh
final favoritesRefreshProvider = Provider<void>((ref) => {});

final searchVocabularyProvider =
    FutureProvider.family<List<VocabularyModel>, String>((ref, query) async {
  final supabase = SupabaseService();
  return await supabase.searchVocabulary(query);
});

final practiceQuestionsProvider =
    FutureProvider.family<List<PracticeQuestion>, Map<String, String?>>(
        (ref, params) async {
  final supabase = SupabaseService();
  return await supabase.getPracticeQuestions(
      type: params['type'], level: params['level']);
});

final dailyStreakProvider =
    FutureProvider.family<DailyStreakModel?, String>((ref, userId) async {
  final supabase = SupabaseService();
  return await supabase.getDailyStreak(userId);
});

final userProgressProvider =
    FutureProvider.family<UserProgressModel?, Map<String, String>>(
        (ref, params) async {
  final supabase = SupabaseService();
  return await supabase.getUserProgress(
    userId: params['userId']!,
    vocabularyId: params['vocabularyId']!,
  );
});

final userAllProgressProvider =
    FutureProvider.family<List<UserProgressModel>, String>((ref, userId) async {
  final supabase = SupabaseService();
  return await supabase.getUserAllProgress(userId);
});

final userFavoritesProvider =
    FutureProvider.family<List<UserFavoriteModel>, String>((ref, userId) async {
  final supabase = SupabaseService();
  return await supabase.getUserFavorites(userId);
});

final practiceAttemptsProvider =
    FutureProvider.family<List<PracticeAttemptModel>, String>(
        (ref, userId) async {
  final supabase = SupabaseService();
  return await supabase.getPracticeAttempts(userId: userId);
});

final quizResultsProvider =
    FutureProvider.family<List<QuizResultModel>, String>((ref, userId) async {
  final supabase = SupabaseService();
  return await supabase.getUserQuizResults(userId);
});
