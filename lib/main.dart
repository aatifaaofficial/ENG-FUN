import 'package:englishfun/app.dart';
import 'package:englishfun/services/storage_service.dart';
import 'package:englishfun/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await SupabaseService().initialize();

  runApp(
    const ProviderScope(
      child: EnglishFunApp(),
    ),
  );
}
