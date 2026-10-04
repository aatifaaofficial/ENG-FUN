// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:englishfun/app.dart';
import 'package:englishfun/services/storage_service.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();

    await tester.pumpWidget(
      const ProviderScope(
        child: EnglishFunApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
