import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../themes/inspection_colors.dart';
import 'cached_reference_image.dart';

/// Capture mode for the dark camera HUD. Tab order in the strip is
/// FILE, PHOTO, VIDEO, AUDIO (per cameraUi.md).
enum CaptureMode { file, photo, video, audio }

extension CaptureModeLabel on CaptureMode {
  String get label => switch (this) {
        CaptureMode.file => 'FILE',
        CaptureMode.photo => 'PHOTO',
        CaptureMode.video => 'VIDEO',
        CaptureMode.audio => 'AUDIO',
      };
}

/// Mode tab strip: four equal tabs with an animated underline indicator.
class CaptureModeTabs extends StatelessWidget {
  const CaptureModeTabs({
    super.key,
    required this.current,
    required this.available,
    required this.onChanged,
  });

  final CaptureMode current;
  final Set<CaptureMode> available;
  final ValueChanged<CaptureMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in CaptureMode.values)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  available.contains(m) ? () => onChanged(m) : null,
              child: Column(
                children: [
                  Text(
                    m.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: m == current
                          ? Colors.white
                          : available.contains(m)
                              ? Colors.white38
                              : Colors.white12,
                      fontWeight:
                          m == current ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: m == current
                          ? InspectionColors.shutterBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// REF reference thumbnail overlay (top-left). Shown for PHOTO/VIDEO modes.
class ReferenceThumbnail extends StatelessWidget {
  const ReferenceThumbnail({
    super.key,
    required this.url,
    required this.isVideo,
    required this.onTap,
  });

  final String url;
  final bool isVideo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.w,
      left: 12.w,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100.w,
          height: 75.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
                color: InspectionColors.refRed.withAlpha(204), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  Container(
                    color: Colors.black87,
                    alignment: Alignment.center,
                    child: Icon(Icons.play_circle_filled,
                        color: Colors.white70, size: 32.sp),
                  )
                else
                  CachedReferenceImage(
                    url,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    cacheHeight: 150,
                    errorBuilder: (_, _, _) =>
                        Container(color: Colors.grey[900]),
                  ),
                Positioned(
                  bottom: 2.w,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(vertical: 2.w),
                    child: Text(
                      'REF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom condition + flag chip row overlay (always shown on capture area).
class ConditionFlagRow extends StatelessWidget {
  const ConditionFlagRow({
    super.key,
    required this.flaggedCount,
    required this.markedNoIssues,
    required this.highlightFlag,
    required this.onTapCondition,
    required this.onTapFlag,
  });

  final int flaggedCount;
  final bool markedNoIssues;
  final bool highlightFlag;
  final VoidCallback onTapCondition;
  final VoidCallback onTapFlag;

  @override
  Widget build(BuildContext context) {
    final bool flagged = flaggedCount > 0;
    final Color condColor = markedNoIssues
        ? Colors.green
        : flagged
            ? Colors.red
            : Colors.white54;
    final IconData condIcon = markedNoIssues
        ? Icons.check_circle_outline
        : flagged
            ? Icons.flag_outlined
            : Icons.radio_button_unchecked;
    final String condLabel = flagged
        ? '$flaggedCount issue(s) flagged'
        : 'No issues — looks good';

    return Positioned(
      bottom: 10.w,
      left: 12.w,
      right: 12.w,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapCondition,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: condColor.withAlpha(153)),
                ),
                child: Row(
                  children: [
                    Icon(condIcon, size: 13.sp, color: condColor),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        condLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: condColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onTapFlag,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
              decoration: BoxDecoration(
                color: highlightFlag
                    ? Colors.orange.withAlpha(51)
                    : Colors.black54,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: highlightFlag ? Colors.orange : Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_outlined,
                      size: 13.sp,
                      color:
                          highlightFlag ? Colors.orange : Colors.white70),
                  SizedBox(width: 4.w),
                  Text(
                    'Flag Issue',
                    style: TextStyle(
                      color: highlightFlag ? Colors.orange : Colors.white70,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 46x46 circular gallery / flash side button.
class HudSideButton extends StatelessWidget {
  const HudSideButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? InspectionColors.flashAmber
              : Colors.white.withAlpha(26),
          border: Border.all(
              color:
                  active ? InspectionColors.flashAmber : Colors.white24),
        ),
        child: Icon(
          icon,
          size: 22.sp,
          color: active
              ? Colors.black87
              : enabled
                  ? Colors.white70
                  : Colors.white24,
        ),
      ),
    );
  }
}

/// 72x72 photo shutter ring.
class ShutterButton extends StatelessWidget {
  const ShutterButton({super.key, required this.onTap, this.enabled = true});

  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? Colors.white : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}

/// 72x72 record/stop toggle for video.
class RecordButton extends StatelessWidget {
  const RecordButton({
    super.key,
    required this.recording,
    required this.onTap,
    this.enabled = true,
  });

  final bool recording;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: recording ? Colors.red : Colors.white, width: 3),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: recording
                  ? Colors.red
                  : enabled
                      ? Colors.white
                      : Colors.white38,
              borderRadius: BorderRadius.circular(recording ? 4.r : 40.r),
            ),
          ),
        ),
      ),
    );
  }
}

/// 72x72 round icon action button (file attach / audio mic-stop).
class HudRoundActionButton extends StatelessWidget {
  const HudRoundActionButton({
    super.key,
    required this.icon,
    required this.fill,
    required this.border,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color fill;
  final Color border;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: border, width: 2.5),
        ),
        child: Icon(icon, color: iconColor, size: 30.sp),
      ),
    );
  }
}

/// Top-right pill badge (Retake / Replace / REC).
class HudPillBadge extends StatelessWidget {
  const HudPillBadge({
    super.key,
    required this.child,
    this.onTap,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.w,
      right: 12.w,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20.r),
            border: border == null ? null : Border.all(color: border!),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-bleed preview of captured media (image/file/audio status) shown inside
/// the capture Stack once media exists for the current field.
class CapturedMediaPreview extends StatelessWidget {
  const CapturedMediaPreview({
    super.key,
    required this.mode,
    this.imagePath,
    this.fileName,
    this.onTapImage,
  });

  final CaptureMode mode;
  final String? imagePath;
  final String? fileName;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CaptureMode.photo:
        final p = imagePath;
        if (p == null) return const SizedBox.shrink();
        final img = p.startsWith('http')
            ? Image.network(p, fit: BoxFit.cover)
            : Image.file(File(p), fit: BoxFit.cover);
        return GestureDetector(
          onTap: onTapImage,
          child: SizedBox.expand(child: img),
        );
      case CaptureMode.file:
        return Container(
          color: const Color(0xFF111111),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file,
                    color: InspectionColors.shutterBlue, size: 64.sp),
                SizedBox(height: 14.w),
                Text(
                  fileName ?? 'File attached',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      case CaptureMode.video:
      case CaptureMode.audio:
        return Container(
          color: const Color(0xFF111111),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode == CaptureMode.video
                    ? Icons.play_circle_outline
                    : Icons.audiotrack,
                color: Colors.white70,
                size: 64.sp,
              ),
              SizedBox(height: 14.w),
              Text(
                mode == CaptureMode.video ? 'Video captured' : 'Audio recorded',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ],
          ),
        );
    }
  }
}

/// Empty-state placeholder for the capture area when no live preview is shown
/// (file/audio modes, or before launching the camera). Tappable to act.
class CaptureEmptyState extends StatelessWidget {
  const CaptureEmptyState({
    super.key,
    required this.icon,
    this.hint,
    this.onTap,
    this.browseLabel,
    this.onBrowse,
  });

  final IconData icon;
  final String? hint;
  final VoidCallback? onTap;
  final String? browseLabel;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF111111),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withAlpha(15), size: 120.sp),
            if (hint != null) ...[
              SizedBox(height: 16.w),
              Text(hint!,
                  style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
            ],
            if (browseLabel != null) ...[
              SizedBox(height: 24.w),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                ),
                onPressed: onBrowse,
                icon: Icon(Icons.folder_open_outlined, size: 16.sp),
                label: Text(browseLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
