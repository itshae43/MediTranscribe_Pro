import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meditranscribe/main.dart';

void main() {
  testWidgets('App should render splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MediTranscribeApp(),
      ),
    );

    // Verify that the app title appears
    expect(find.text('MediTranscribe'), findsOneWidget);
  });
}
