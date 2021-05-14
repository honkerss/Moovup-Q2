import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moovup_question_2/main.dart';

void main() {
    testWidgets('testing main.dart', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(CustomScrollView), findsOneWidget);
    });
}
