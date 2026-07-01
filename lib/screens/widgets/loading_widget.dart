import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 140.w,
            width: 140.w,
            child: Lottie.asset('assets/lottie/loading_lottie.json'),
          ),
          if (message != null) ...[
            SizedBox(height: 8.w),
            Text(
              message!,
              style:
                  TextStyle(fontSize: 14.sp, color: colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
