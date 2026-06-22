import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    // Navigation happens via GoRouter redirect when isAuthenticated flips.
    ref.read(authControllerProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.w),
              SvgPicture.asset('assets/images/certifide.svg', height: 64.w),
              SizedBox(height: 40.w),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.w),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              SizedBox(height: 36.w),
              CustomTextField(
                controller: _email,
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 14.w),
              CustomTextField(
                controller: _password,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20.sp),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (auth.errorMessage != null) ...[
                SizedBox(height: 16.w),
                Text(
                  auth.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.error, fontSize: 13.sp),
                ),
              ],
              SizedBox(height: 28.w),
              CustomButton(
                text: 'Sign In',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
