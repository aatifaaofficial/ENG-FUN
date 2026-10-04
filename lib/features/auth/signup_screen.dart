// lib/features/auth/signup_screen.dart
// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:englishfun/core/widgets/custom_widgets.dart';
import 'package:englishfun/services/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class RegisterScreen extends SignupScreen {
  const RegisterScreen({super.key});
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  String _debugError = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() => _debugError = '');

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _debugError = 'All fields are required.');
      return;
    }
    if (password != confirm) {
      setState(() => _debugError = 'Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setState(() => _debugError = 'Password must be at least 6 characters.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _debugError = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _debugError = '';
    });

    try {
      await ref.read(authControllerProvider.notifier).signUp(
            email: email,
            password: password,
            name: name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.')),
        );
        context.go('/login');
      }
    } catch (e) {
      String friendlyMessage = 'Signup failed. Please try again.';
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('429') || errorStr.contains('rate limit')) {
        friendlyMessage =
            'Too many sign-up attempts with this email.\nPlease wait a few minutes and try again, or use a different email.';
      } else if (errorStr.contains('already registered')) {
        friendlyMessage = 'This email is already registered. Please login.';
      } else if (errorStr.contains('invalid')) {
        friendlyMessage = 'Please enter a valid email address.';
      } else if (errorStr.contains('network')) {
        friendlyMessage = 'Network error. Check your internet connection.';
      }

      setState(() {
        _debugError = friendlyMessage;
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('👤',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hintText: 'Min 6 characters',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirm Password',
              hintText: 'Re-enter password',
              controller: _confirmPasswordController,
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 24),
            RoundedButton(
              label: _isLoading ? 'Creating...' : 'Sign Up',
              onPressed: _isLoading ? null : _handleSignup,
            ),
            const SizedBox(height: 16),
            if (_debugError.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _debugError,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.go('/login'),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
