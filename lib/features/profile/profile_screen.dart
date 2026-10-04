// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, use_super_parameters, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:englishfun/navigation/app_router.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/theme/app_theme.dart';
import 'package:englishfun/core/theme/theme_provider.dart'; // 👈 added
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/services/auth_provider.dart';
import 'package:englishfun/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      return _buildNoSessionUI(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('users')
            .stream(primaryKey: ['id']).eq('id', currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('UI Rendering Error in ProfileScreen: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoProfileDataUI(context);
          }

          try {
            final rawData = snapshot.data!.first;
            final user = UserModel.fromJson(rawData);
            return _buildProfileContent(context, user);
          } catch (e) {
            print('Error parsing user data: $e');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.data_usage, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to parse profile data. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // No session UI (full Scaffold)
  Widget _buildNoSessionUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Please sign in to view your profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You are not currently logged in',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  // No profile data UI
  Widget _buildNoProfileDataUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No profile data found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your profile information is not available in the database.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Main profile content with working dark mode switch
  Widget _buildProfileContent(BuildContext context, UserModel user) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                (user.avatar.isNotEmpty) ? user.avatar : '👤',
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User info
          Text(
            user.name,
            style: Theme.of(context).textTheme.displayMedium ??
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium ??
                const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _StatCard(
                icon: '📚',
                label: 'Words Learned',
                value: '${user.totalWordsLearned}',
              ),
              _StatCard(
                icon: '🔥',
                label: 'Daily Streak',
                value: '${user.dailyStreak}',
              ),
              _StatCard(
                icon: '🎯',
                label: 'Accuracy',
                value: '${user.accuracy.toStringAsFixed(0)}%',
              ),
              _StatCard(
                icon: '⭐',
                label: 'Total XP',
                value: '${user.totalXP}',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Settings
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dark_mode),
                    const SizedBox(width: 12),
                    const Text('Dark Mode'),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
