import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: colors.error),
            SizedBox(height: 12.w),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14.sp, color: colors.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.w),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
