import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/repositories/auth_repository.dart';
import 'package:inspektor/screens/authentication/login_screen.dart';
import 'package:inspektor/services/user_service.dart';
import 'package:inspektor/themes/app_theme.dart';

import '../support/fake_http.dart';

class _FakeUserService extends UserService {
  _FakeUserService() : super(storage: const FlutterSecureStorage());
  String? token;
  @override
  Future<void> saveToken(String t) async => token = t;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> saveUser(Map<String, dynamic> u) async {}
  @override
  Future<void> clearAll() async => token = null;
}

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(theme: AppTheme.light, home: child),
    );

void main() {
  testWidgets('renders the login form', (tester) async {
    await tester.pumpWidget(ProviderScope(child: _wrap(const LoginScreen())));
    await tester.pump();
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('shows error message after a failed login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = AuthRepository(
      api: apiWrapperWith((_) => (status: 401, body: {'message': 'Bad creds'})),
      userService: _FakeUserService(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: _wrap(const LoginScreen()),
    ));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'a@b.c');
    await tester.enterText(find.byType(TextField).last, 'pw');
    await tester.tap(find.text('Sign In'));
    await tester.pump(); // login starts (isLoading)
    await tester.pump(const Duration(milliseconds: 400)); // async settles

    expect(find.text('Bad creds'), findsOneWidget);
  });
}
