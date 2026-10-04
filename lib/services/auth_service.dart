import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/services/storage_service.dart';

class AuthService {
  const AuthService(this._storage);

  final StorageService _storage;

  Future<UserProfile?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.length < 6) {
      return null;
    }

    final registeredUsers = _storage.registeredUsers;
    for (final user in registeredUsers) {
      if ((user['email'] ?? '').toLowerCase() == cleanEmail) {
        return null;
      }
    }

    final updated = [...registeredUsers, {
      'name': cleanName,
      'email': cleanEmail,
      'password': _storage.encodePassword(password),
    }];

    await _storage.saveRegisteredUsers(updated);
    return UserProfile(name: cleanName, email: cleanEmail);
  }

  Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    for (final user in _storage.registeredUsers) {
      final emailMatch = (user['email'] ?? '').toLowerCase() == cleanEmail;
      final passwordMatch = (user['password'] ?? '') == _storage.encodePassword(password);

      if (emailMatch && passwordMatch) {
        return UserProfile(
          name: user['name'] ?? 'Learner',
          email: cleanEmail,
        );
      }
    }

    return null;
  }
}
