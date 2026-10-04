// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/theme/app_theme.dart';
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/services/auth_provider.dart';
import 'package:englishfun/models/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || _isSigningOut) {
      return _buildSessionNotFoundError(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('English Fun'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              setState(() => _isSigningOut = true);
              try {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              } catch (e) {
                setState(() => _isSigningOut = false);
                print("Sign out error: $e");
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // ✅ FIX: Use the correct table name 'users' instead of 'profiles'
        stream: _supabase
            .from('users')
            .stream(primaryKey: ['id']).eq('id', currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error in HomeScreen Stream: ${snapshot.error}');
            return _buildErrorView(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoProfileRowView(currentUser);
          }

          try {
            final rawData = snapshot.data!.first;
            final user = UserModel.fromJson(rawData);
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: _buildHomeContent(context, user),
            );
          } catch (e) {
            print('JSON parsing error: $e');
            return _buildErrorView(
                'Failed to parse user data. Check column names in UserModel.');
          }
        },
      ),
    );
  }

  // ------------------- ERROR VIEWS -------------------
  Widget _buildErrorView(String errorDetails) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Details: $errorDetails',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfileRowView(User currentUser) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_disabled_outlined,
                size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Profile Record Missing',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticated as ${currentUser.email}, but no record exists in the "users" table with this User ID.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionNotFoundError(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'User session not found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- MAIN CONTENT -------------------
  Widget _buildHomeContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            backgroundColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${user.name}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatBox(
                      icon: '🔥',
                      label: 'Streak',
                      value: '${user.dailyStreak}',
                      subValue: 'days',
                    ),
                    _StatBox(
                      icon: '⭐',
                      label: 'XP',
                      value: '${user.totalXP}',
                      subValue: 'points',
                    ),
                    _StatBox(
                      icon: '📚',
                      label: 'Words',
                      value: '${user.totalWordsLearned}',
                      subValue: 'learned',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Continue Learning',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: '✏️',
            title: 'Daily Practice',
            subtitle: 'Learn and practice',
            onTap: () => context.go('/practice'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: '📚',
            title: 'Vocabulary',
            subtitle: 'Browse word list',
            onTap: () => context.go('/vocabulary'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            icon: '🎴',
            title: 'Flashcards',
            subtitle: 'Practice with cards',
            onTap: () => context.go('/flashcard'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subValue;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            subValue,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
