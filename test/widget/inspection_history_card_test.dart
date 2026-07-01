import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/models/inspection_history_model.dart';
import 'package:inspektor/screens/inspection/widgets/inspection_list.dart';

InspectionHistory _item({
  required String status,
  String? reportUrl,
}) =>
    InspectionHistory(
      id: '1',
      inspectorName: 'Riyan',
      status: status,
      date: DateTime(2024, 1, 15, 15, 38),
      vehicleInfo: const {
        'registration_number': 'KL45W5486',
        'make_model': 'Skoda Kushaq',
      },
      links: reportUrl != null ? {'view': reportUrl} : null,
    );

Future<void> _pump(WidgetTester tester, Widget card) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(home: Scaffold(body: card)),
  ));
  await tester.pump();
}

void main() {
  testWidgets('completed report shows Reg, status pill, labels and view eye',
      (tester) async {
    await _pump(
      tester,
      InspectionHistoryCard(
          _item(status: 'approved', reportUrl: 'https://r.example/1')),
    );

    expect(find.text('Reg: KL45W5486'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.text('Make & Model'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
  });

  testWidgets('draft shows the view eye AND Resume together', (tester) async {
    await _pump(
      tester,
      InspectionHistoryCard(
        _item(status: 'draft', reportUrl: 'https://r.example/2'),
        forceResume: true,
        onResume: (_) {},
      ),
    );

    expect(find.text('DRAFT'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('draft without a report url shows Resume only (no eye)',
      (tester) async {
    await _pump(
      tester,
      InspectionHistoryCard(
        _item(status: 'draft'),
        forceResume: true,
        onResume: (_) {},
      ),
    );

    expect(find.text('Resume'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });
}
