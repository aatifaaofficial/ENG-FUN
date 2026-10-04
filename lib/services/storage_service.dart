import 'dart:convert';

import 'package:englishfun/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _storage {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call StorageService.instance.init() before use.',
      );
    }
    return _prefs!;
  }

  static const String _onboardingCompletedKey = 'onboardingCompleted';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _rememberMeKey = 'rememberMe';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _registeredUsersKey = 'registeredUsers';

  bool get onboardingCompleted => _storage.getBool(_onboardingCompletedKey) ?? false;
  Future<void> setOnboardingCompleted(bool value) async {
    await _storage.setBool(_onboardingCompletedKey, value);
  }

  bool get isLoggedIn => _storage.getBool(_isLoggedInKey) ?? false;
  Future<void> setLoggedIn(bool value) async {
    await _storage.setBool(_isLoggedInKey, value);
  }

  bool get rememberMe => _storage.getBool(_rememberMeKey) ?? false;
  Future<void> setRememberMe(bool value) async {
    await _storage.setBool(_rememberMeKey, value);
  }

  String get userName => _storage.getString(_userNameKey) ?? 'English Learner';
  Future<void> setUserName(String value) async {
    await _storage.setString(_userNameKey, value);
  }

  String get userEmail => _storage.getString(_userEmailKey) ?? '';
  Future<void> setUserEmail(String value) async {
    await _storage.setString(_userEmailKey, value);
  }

  UserProfile get userProfile {
    return UserProfile(
      name: userName,
      email: userEmail,
      totalXp: _storage.getInt('userTotalXp') ?? 0,
      streak: _storage.getInt('userStreak') ?? 0,
      wordsLearned: _storage.getInt('userWordsLearned') ?? 0,
      quizzesCompleted: _storage.getInt('userQuizzesCompleted') ?? 0,
      averageAccuracy: _storage.getDouble('userAverageAccuracy') ?? 0.0,
    );
  }

  Future<void> saveUserProfile(UserProfile user) async {
    await setUserName(user.name);
    await setUserEmail(user.email);
    await _storage.setInt('userTotalXp', user.totalXp);
    await _storage.setInt('userStreak', user.streak);
    await _storage.setInt('userWordsLearned', user.wordsLearned);
    await _storage.setInt('userQuizzesCompleted', user.quizzesCompleted);
    await _storage.setDouble('userAverageAccuracy', user.averageAccuracy);
  }

  Future<void> saveRegisteredUsers(List<Map<String, String>> users) async {
    final encodedUsers = users.map((user) => jsonEncode(user)).toList();
    await _storage.setStringList(_registeredUsersKey, encodedUsers);
  }

  List<Map<String, String>> get registeredUsers {
    final raw = _storage.getStringList(_registeredUsersKey) ?? const <String>[];
    final users = <Map<String, String>>[];
    for (final item in raw) {
      final decoded = jsonDecode(item);
      if (decoded is Map<String, dynamic>) {
        users.add({
          'name': (decoded['name'] ?? 'User').toString(),
          'email': (decoded['email'] ?? '').toString(),
          'password': (decoded['password'] ?? '').toString(),
        });
      }
    }
    return users;
  }

  String encodePassword(String password) {
    return base64.encode(utf8.encode(password));
  }

  Future<void> clearSession() async {
    await _storage.remove(_isLoggedInKey);
    await _storage.remove(_userNameKey);
    await _storage.remove(_userEmailKey);
    await _storage.remove('userTotalXp');
    await _storage.remove('userStreak');
    await _storage.remove('userWordsLearned');
    await _storage.remove('userQuizzesCompleted');
    await _storage.remove('userAverageAccuracy');
    await _storage.remove(_rememberMeKey);
  }

  Future<void> clearAllAppData() async {
    await _storage.remove(_onboardingCompletedKey);
    await clearSession();
  }
}
