import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_submit_controller.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../themes/inspection_colors.dart';

class InspectionSuccessArgs {
  const InspectionSuccessArgs({this.outcome});
  final SubmitOutcome? outcome;
}

class InspectionSuccessScreen extends StatelessWidget {
  const InspectionSuccessScreen({super.key, this.args});

  final InspectionSuccessArgs? args;

  @override
  Widget build(BuildContext context) {
    final outcome = args?.outcome;
    final queued = outcome?.queued ?? false;
    final result = outcome?.result;
    final reportUrl = result?.redirectUrl;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: InspectionColors.scaffold,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SuccessCircle(queued: queued),
                  SizedBox(height: 32.h),
                  Text(
                    queued ? 'Saved Offline' : 'Inspection Submitted!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    queued
                        ? 'It will upload automatically when you are back online.'
                        : 'Your inspection has been created successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (result != null) ...[
                    SizedBox(height: 32.h),
                    _DetailsCard(result: result),
                  ],
                  SizedBox(height: 32.h),
                  _HomepageButton(
                    onPressed: () => context.goNamed(RouteNames.home),
                  ),
                  if (reportUrl != null) ...[
                    SizedBox(height: 16.h),
                    _ViewReportButton(
                      onPressed: () => _launchUrl(context, reportUrl),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the URL')),
    );
  }
}

class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle({required this.queued});

  final bool queued;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: queued
              ? const [InspectionColors.accent, InspectionColors.navBlue]
              : InspectionColors.successGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: (queued
                    ? InspectionColors.accent
                    : InspectionColors.successGradient.first)
                .withAlpha(102),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Icon(
        queued ? Icons.cloud_off : Icons.check_rounded,
        color: Colors.white,
        size: 56.sp,
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.result});

  final SubmitResult result;

  @override
  Widget build(BuildContext context) {
    final inspectionId = result.inspectionId;
    final uuid = result.uuid;
    final reportUrl = result.redirectUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: InspectionColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20.sp, color: Colors.grey[400]),
              SizedBox(width: 8.w),
              Text(
                'Inspection Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (inspectionId != null) ...[
            _DetailRow(label: 'Inspection ID', value: '#$inspectionId'),
            SizedBox(height: 8.h),
          ],
          if (uuid != null) ...[
            _DetailRow(label: 'UUID', value: uuid, isSmall: true),
            SizedBox(height: 12.h),
          ],
          if (reportUrl != null) ...[
            Divider(color: Colors.white.withAlpha(51)),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.link, size: 18.sp, color: Colors.blue[300]),
                SizedBox(width: 8.w),
                Text(
                  'Report URL',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _launchUrl(context, reportUrl),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: reportUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
              child: Text(
                reportUrl,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue[300],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue[300],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isSmall = false,
  });

  final String label;
  final String value;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 12.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomepageButton extends StatelessWidget {
  const _HomepageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: InspectionColors.homeButtonGradient,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: InspectionColors.homeButtonGradient.first.withAlpha(102),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          label: Text(
            'Go to Homepage',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewReportButton extends StatelessWidget {
  const _ViewReportButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withAlpha(51), width: 1.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: Icon(Icons.open_in_new, color: Colors.white, size: 20.sp),
        label: Text(
          'View Report',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
