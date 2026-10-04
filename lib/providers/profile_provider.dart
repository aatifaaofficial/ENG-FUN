import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = Provider<UserProfile>((ref) {
  return ref.watch(userProvider);
});
