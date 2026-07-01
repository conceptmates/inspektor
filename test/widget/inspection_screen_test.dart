import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/screens/inspection/inspection_screen.dart';
import 'package:inspektor/services/local_inspection_service.dart';
import 'package:inspektor/themes/app_theme.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hive_insp_screen');
    Hive.init(dir.path);
    await Hive.openBox<String>(LocalInspectionService.boxName);
  });

  tearDown(() async {
    await Hive.box<String>(LocalInspectionService.boxName).close();
    await Hive.deleteBoxFromDisk(LocalInspectionService.boxName,
        path: dir.path);
    dir.deleteSync(recursive: true);
  });

  // Skipped: the inspection screen is being rebuilt to the exact dark UI;
  // this test (and a camera/Hive harness) is rewritten with that screen.
  testWidgets('renders the first field from the resumed draft', skip: true,
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final svc =
        LocalInspectionService(Hive.box<String>(LocalInspectionService.boxName));
    await svc.saveDraft(LocalInspection(
      id: 't',
      createdAt: DateTime(2026, 6, 22),
      inspectionTemplate: const {
        'template_type': {'name': 'default'},
        'structure': {
          'sections': [
            {
              'id': 1,
              'name': 'general',
              'title': 'General',
              'order': 1,
              'fields': [
                {
                  'id': 1,
                  'field_id': 'mileage',
                  'title': 'Mileage',
                  'field_type': 'text',
                  'order': 1,
                },
                {
                  'id': 2,
                  'field_id': 'notes',
                  'title': 'Notes',
                  'field_type': 'text',
                  'order': 2,
                },
              ],
            },
          ],
        },
      },
    ));

    await tester.pumpWidget(ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.light,
          home: const InspectionScreen(),
        ),
      ),
    ));
    // Not pumpAndSettle: the brief loader's CircularProgressIndicator animates
    // forever and would hang settle. A few fixed pumps let the post-frame
    // resumeDraft run and the form render.
    await tester.pump(); // first frame (loader) → schedules post-frame resume
    await tester.pump(const Duration(milliseconds: 50)); // resume + rebuild
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Mileage'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget); // first of two fields
  });
}
