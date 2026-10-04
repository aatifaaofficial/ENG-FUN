import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends StateNotifier<UserProfile> {
  UserNotifier(this._storage) : super(_storage.userProfile);

  final StorageService _storage;

  Future<void> refresh() async {
    state = _storage.userProfile;
  }

  Future<void> setProfile(UserProfile profile) async {
    await _storage.saveUserProfile(profile);
    state = profile;
  }

  Future<void> updateStats({
    int? totalXp,
    int? streak,
    int? wordsLearned,
    int? quizzesCompleted,
    double? averageAccuracy,
  }) async {
    final updated = state.copyWith(
      totalXp: totalXp,
      streak: streak,
      wordsLearned: wordsLearned,
      quizzesCompleted: quizzesCompleted,
      averageAccuracy: averageAccuracy,
    );
    await _storage.saveUserProfile(updated);
    state = updated;
  }

  Future<void> clear() async {
    await _storage.clearSession();
    state = UserProfile.empty();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserProfile>(
  (ref) => UserNotifier(StorageService.instance),
);
