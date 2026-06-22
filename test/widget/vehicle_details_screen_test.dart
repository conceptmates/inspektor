import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/repositories/inspection_repository.dart';
import 'package:inspektor/screens/inspection/vehicle_details_screen.dart';
import 'package:inspektor/themes/app_theme.dart';

import '../support/fake_http.dart';

void main() {
  testWidgets('renders the vehicle form with loaded makes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = InspectionRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': [
              {'id': 1, 'name': 'Corolla', 'brand': {'id': 2, 'name': 'Toyota'}},
            ],
          },
        )));

    await tester.pumpWidget(ProviderScope(
      overrides: [inspectionRepositoryProvider.overrideWithValue(repo)],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.light,
          home: const VehicleDetailsScreen(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Vehicle Details'), findsOneWidget);
    expect(find.text('Make'), findsOneWidget);
    expect(find.text('Transmission'), findsOneWidget);
    expect(find.text('Start Inspection'), findsOneWidget);
  });
}
