import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Inspektor'), findsOneWidget);
  });
}
