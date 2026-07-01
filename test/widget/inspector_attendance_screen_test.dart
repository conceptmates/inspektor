import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/screens/attendance/inspector_attendance_screen.dart';

Widget _wrap() => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => const MaterialApp(
        home: InspectorAttendanceScreen(),
      ),
    );

void main() {
  testWidgets('renders the check-in tracker in the off-clock state',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());
    await tester.pump();

    // App bar + leaves entry point.
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Leaves'), findsOneWidget);

    // Off-clock hero + primary action.
    expect(find.text('Ready to start your shift?'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);

    // Manual logger + empty state.
    expect(find.text('Add Attendance Manually'), findsOneWidget);
    expect(find.text('No attendance yet today'), findsOneWidget);
  });

  testWidgets('tapping "Add Attendance Manually" opens the manual sheet',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap());
    await tester.pump();

    await tester.tap(find.text('Add Attendance Manually'));
    await tester.pumpAndSettle();

    expect(find.text('Add Attendance'), findsOneWidget);
    expect(find.text('Log a working session manually.'), findsOneWidget);
    expect(find.text('Save Attendance'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
  });
}
