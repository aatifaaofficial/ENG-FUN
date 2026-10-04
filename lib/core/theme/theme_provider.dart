import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key for storing theme preference
const String _themeKey = 'theme_mode';

// Provider to read/write theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_themeKey) ?? 1;
      state = ThemeMode.values[index];
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    await _saveTheme(newMode);
  }

  // Set a specific theme
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _saveTheme(mode);
  }

  // Save to SharedPreferences
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (_) {}
  }
}
