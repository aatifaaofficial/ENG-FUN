import 'package:englishfun/features/auth/login_screen.dart';
import 'package:englishfun/features/auth/signup_screen.dart';
import 'package:englishfun/features/flashcard/flashcard_screen.dart';
import 'package:englishfun/features/home/home_screen.dart';
import 'package:englishfun/features/onboarding/onboarding_screen.dart';
import 'package:englishfun/features/practice/practice_screen.dart';
import 'package:englishfun/features/profile/profile_screen.dart';
import 'package:englishfun/features/quiz/quiz_screen.dart';
import 'package:englishfun/features/splash/splash_screen.dart';
import 'package:englishfun/features/vocabulary/vocabulary_detail_screen.dart';
import 'package:englishfun/features/vocabulary/vocabulary_list_screen.dart';
import 'package:englishfun/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String home = '/home';
  static const String practice = '/practice';
  static const String vocabulary = '/vocabulary';
  static const String flashcards = '/flashcards';
  static const String quiz = '/quiz';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String splash = '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (location == '/') {
        return null;
      }

      if (location == '/onboarding' && authState.isLoggedIn) {
        return '/home';
      }

      if ((location == '/login' || location == '/register') && authState.isLoggedIn) {
        return '/home';
      }

      if ((location == '/home' ||
              location == '/practice' ||
              location == '/vocabulary' ||
              location.startsWith('/vocabulary/') ||
              location == '/flashcards' ||
              location == '/quiz' ||
              location == '/profile') &&
          !authState.isLoggedIn) {
        return '/login';
      }

      if (!authState.onboardingCompleted &&
          location != '/onboarding' &&
          location != '/login' &&
          location != '/register' &&
          location != '/') {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/practice', builder: (context, state) => const PracticeScreen()),
      GoRoute(path: '/vocabulary', builder: (context, state) => const VocabularyListScreen()),
      GoRoute(
        path: '/vocabulary/:id',
        builder: (context, state) => VocabularyDetailScreen(vocabularyId: state.pathParameters['id'] ?? '1'),
      ),
      GoRoute(path: '/flashcards', builder: (context, state) => const FlashcardsScreen()),
      GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
