import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_submit_controller.dart';

class InspectionSuccessArgs {
  const InspectionSuccessArgs({this.outcome});
  final SubmitOutcome? outcome;
}

class InspectionSuccessScreen extends StatelessWidget {
  const InspectionSuccessScreen({super.key, this.args});

  final InspectionSuccessArgs? args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final outcome = args?.outcome;
    final queued = outcome?.queued ?? false;
    final result = outcome?.result;
    final reportUrl = result?.redirectUrl;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                queued ? Icons.cloud_off : Icons.check_circle,
                size: 88.sp,
                color: queued ? colors.tertiary : Colors.green,
              ),
              SizedBox(height: 20.w),
              Text(
                queued ? 'Saved offline' : 'Inspection submitted',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.w),
              Text(
                queued
                    ? 'It will upload automatically when you are back online.'
                    : 'Your inspection has been submitted successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (result?.inspectionId != null) ...[
                SizedBox(height: 16.w),
                Text('ID: ${result!.inspectionId}',
                    style: theme.textTheme.bodySmall),
              ],
              if (reportUrl != null) ...[
                SizedBox(height: 24.w),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View report'),
                  onPressed: () =>
                      launchUrl(Uri.parse(reportUrl), mode: LaunchMode.externalApplication),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: reportUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report link copied')),
                    );
                  },
                ),
              ],
              SizedBox(height: 32.w),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(RouteNames.home),
                  child: const Text('Go to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
