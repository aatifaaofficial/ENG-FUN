// lib/presentation/auth/login_screen.dart
// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/core/constants/app_constants.dart';
import 'package:englishfun/services/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: email,
            password: password,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Login failed. Please try again.';
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('invalid login credentials') ||
            errorStr.contains('auth_exception') ||
            errorStr.contains('invalid password') ||
            errorStr.contains('user not found')) {
          errorMsg = 'Invalid email or password';
        } else if (errorStr.contains('network') ||
            errorStr.contains('socket') ||
            errorStr.contains('timeout')) {
          errorMsg = 'Network error. Please check your connection.';
        } else {
          errorMsg = 'Error: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.loginWithEmail),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '👤',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 32),
            RoundedButton(
              label: isLoading ? 'Logging in...' : 'Login',
              onPressed: isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: isLoading ? null : () => context.go('/signup'),
                child: RichText(
                  text: TextSpan(
                    text: AppStrings.dontHaveAccount,
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: AppStrings.signUp,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
