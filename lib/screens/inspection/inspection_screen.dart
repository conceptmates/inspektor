import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_session_controller.dart';
import '../../controllers/inspection_submit_controller.dart';
import '../../controllers/media_capture_controller.dart';
import '../../data/inspection_submission_builder.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../models/inspection_template_model.dart';
import '../../models/local_inspection.dart';
import '../../services/api/api_result.dart';
import '../../themes/inspection_colors.dart';
import 'inspection_success_screen.dart';
import 'widgets/cached_reference_image.dart';
import 'widgets/camera_hud.dart';
import 'widgets/field_info_sheet.dart';
import 'widgets/flag_issues_sheet.dart';
import 'widgets/section_camera_card.dart';
import 'widgets/section_video_camera_card.dart';
import 'widgets/sections_drawer.dart';
import 'widgets/video_preview_screen.dart';

const _maxMultiImages = 11;

/// The dark inspection capture screen: one field at a time, with a white
/// field-type-badge card for non-media fields and a full dark camera HUD for
/// media fields. Matches formUi.md + cameraUi.md.
class InspectionScreen extends ConsumerStatefulWidget {
  const InspectionScreen({super.key, this.resumeInspectionId});

  /// When set (resuming a server draft from the reports list), the screen pulls
  /// the draft from GET /{id}/resume and merges its saved answers before render.
  final int? resumeInspectionId;

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _sectionIndex = 0;
  int _itemIndex = 0;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(inspectionSessionControllerProvider.notifier);
      final explicitId = widget.resumeInspectionId;
      if (explicitId != null) {
        // Resuming a server draft (possibly created on another device/session).
        notifier.resumeFromServer(explicitId);
      } else if (ref.read(inspectionSessionControllerProvider) == null) {
        // No active session: restore the local draft, then — if it was already
        // initialized on the server — overlay any server-side progress (answers
        // + media uploaded from another session). Local edits always win.
        if (notifier.resumeDraft()) {
          final id = ref.read(inspectionSessionControllerProvider)?.inspectionId;
          if (id != null) notifier.resumeFromServer(id);
        }
      }
    });
  }

  List<InspectionSection> _sections(InspectionInitializationResponse t) =>
      [...t.structure.sections]..sort((a, b) => a.order.compareTo(b.order));

  List<InspectionField> _fields(InspectionSection s) =>
      [...s.fields]..sort((a, b) => a.order.compareTo(b.order));

  void _goNext(List<InspectionSection> sections) {
    final fields = _fields(sections[_sectionIndex]);
    if (!_passesFieldGate(fields[_itemIndex.clamp(0, fields.length - 1)])) {
      return;
    }
    if (_itemIndex < fields.length - 1) {
      setState(() => _itemIndex++);
    } else if (_sectionIndex < sections.length - 1) {
      _flushLeavingSection();
      setState(() {
        _sectionIndex++;
        _itemIndex = 0;
      });
      ref
          .read(inspectionSessionControllerProvider.notifier)
          .setSection(_sectionIndex);
    } else {
      _confirmSubmit();
    }
  }

  void _goPrev(List<InspectionSection> sections) {
    if (_itemIndex > 0) {
      setState(() => _itemIndex--);
    } else if (_sectionIndex > 0) {
      _flushLeavingSection();
      setState(() {
        _sectionIndex--;
        _itemIndex = _fields(sections[_sectionIndex]).length - 1;
      });
      ref
          .read(inspectionSessionControllerProvider.notifier)
          .setSection(_sectionIndex);
    }
  }

  /// Per-field gate on Next/Finish (ported from old app): required/regno fields
  /// must be filled, and a captured photo/video must have its condition recorded
  /// (flagged or marked no-issues) before advancing.
  bool _passesFieldGate(InspectionField field) {
    final draft = ref.read(inspectionSessionControllerProvider);
    if (draft == null) return true;
    final key = fieldKey(field);
    final processed = _fieldProcessed(field, draft);

    if ((field.isRequired || _isRegField(field)) && !processed) {
      _gateSnack('"${field.title ?? key}" is required and must be '
          'filled before proceeding.');
      return false;
    }

    final isPhotoOrVideo = field.fieldType == 'image' ||
        field.fieldType == 'video' ||
        field.hasImage ||
        field.hasVideo ||
        field.hasMultipleImages;
    if (isPhotoOrVideo && processed) {
      final flagged = draft.itemFlaggedIssues[key] ?? const <String>[];
      final value = draft.itemValues[key];
      final marked =
          flagged.isNotEmpty || value == 'no_issues' || value == 'flagged';
      if (!marked) {
        _gateSnack('Please flag an issue or mark as no issues before '
            'proceeding.');
        return false;
      }
    }
    return true;
  }

  void _gateSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  /// Save-step the section being left to the server so progress persists
  /// incrementally (batch per section, not per field). Online-only and
  /// fire-and-forget: offline it no-ops via ApiNetworkError and the draft is
  /// replayed at submit; save-step is idempotent (re-sending overwrites).
  void _flushLeavingSection() {
    final draft = ref.read(inspectionSessionControllerProvider);
    final id = draft?.inspectionId;
    final tmpl = draft?.inspectionTemplate;
    if (draft == null || id == null || tmpl == null) return;
    final sections =
        _sections(InspectionInitializationResponse.fromJson(tmpl));
    if (_sectionIndex < 0 || _sectionIndex >= sections.length) return;
    final section = sections[_sectionIndex];
    final items = buildSectionItems(section: section, draft: draft);
    if (items.isEmpty) return;
    unawaited(ref.read(inspectionRepositoryProvider).saveStep(
          id: id,
          section: section.name ?? 'section_${section.id}',
          items: items,
        ));
  }

  void _jumpTo(int sectionIndex, int fieldIndex) {
    if (sectionIndex != _sectionIndex) _flushLeavingSection();
    setState(() {
      _sectionIndex = sectionIndex;
      _itemIndex = fieldIndex;
    });
    ref
        .read(inspectionSessionControllerProvider.notifier)
        .setSection(sectionIndex);
  }

  Future<void> _confirmStop() async {
    final stop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Inspection?'),
        content: const Text(
            'Your progress will be saved and you can continue later. '
            'Do you want to stop?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Stop')),
        ],
      ),
    );
    if (stop == true && mounted) _leave();
  }

  /// Inspection is entered via `go` (sole page on the stack), so `pop()` would
  /// throw `nothing to pop`. Pop if we can, else fall back to home.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.home);
    }
  }

  Future<void> _confirmSubmit() async {
    // Validate required fields client-side first (ported from the old app) so we
    // never POST an incomplete inspection and bounce off a server 422 (e.g.
    // "The registration number field is required").
    final draft = ref.read(inspectionSessionControllerProvider);
    if (draft?.inspectionTemplate != null) {
      final template =
          InspectionInitializationResponse.fromJson(draft!.inspectionTemplate!);
      final missing = _missingRequired(_sections(template), draft);
      if (missing.isNotEmpty) {
        await _showRequiredFieldsSheet(missing);
        return;
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final submitting =
            ref.watch(inspectionSubmitControllerProvider).isSubmitting;
        return AlertDialog(
          title: const Text('Submit Inspection'),
          content:
              const Text('Are you sure you want to submit the inspection data?'),
          actions: [
            TextButton(
                onPressed: submitting ? null : () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx, true),
              child: submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit'),
            ),
          ],
        );
      },
    );
    if (!(ok ?? false)) return;

    // Hold submission behind a blocking sheet until every still-uploading photo
    // finishes — so a burst captured just before Submit is never dropped
    // mid-upload. (submit() also settles internally; this is the visible wait.)
    await _awaitPendingUploads();
    if (!mounted) return;

    final outcome =
        await ref.read(inspectionSubmitControllerProvider.notifier).submit();
    if (!mounted) return;
    if (outcome.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(outcome.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
      return;
    }
    context.goNamed(
      RouteNames.inspectionSuccess,
      extra: InspectionSuccessArgs(outcome: outcome),
    );
  }

  /// Shows a non-dismissible sheet while photos are still uploading and closes
  /// it once every capture settles. No-op when nothing is in flight.
  Future<void> _awaitPendingUploads() async {
    final capture = ref.read(mediaCaptureControllerProvider.notifier);
    if (!capture.hasInFlight) return;
    final navigator = Navigator.of(context);
    final sheetClosed = showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UploadWaitSheet(),
    );
    try {
      await capture.settle();
    } finally {
      if (mounted && navigator.canPop()) navigator.pop();
    }
    await sheetClosed; // wait for the sheet to finish dismissing
  }

  // --- required-field validation (ported from old app) ----------------------

  bool _isRegField(InspectionField f) {
    final id = f.fieldId?.toLowerCase() ?? '';
    return id == 'regno' || id.contains('reg');
  }

  /// Required (or registration-number) fields with no value/media, across all
  /// sections. The registration number is always treated as required because the
  /// server rejects an empty one even when the template doesn't flag it.
  List<({int section, int field, String label})> _missingRequired(
      List<InspectionSection> sections, LocalInspection draft) {
    final missing = <({int section, int field, String label})>[];
    for (var s = 0; s < sections.length; s++) {
      final fields = _fields(sections[s]);
      for (var i = 0; i < fields.length; i++) {
        final f = fields[i];
        final mustHave = f.isRequired || _isRegField(f);
        if (mustHave && !_fieldProcessed(f, draft)) {
          missing.add((
            section: s,
            field: i,
            label: '${f.title ?? fieldKey(f)}${_missingTypeSuffix(f)}',
          ));
        }
      }
    }
    return missing;
  }

  String _missingTypeSuffix(InspectionField f) {
    if (f.fieldType == 'image' || f.hasImage || f.hasMultipleImages) {
      return ' (photo)';
    }
    if (f.fieldType == 'video' || f.hasVideo) return ' (video)';
    if (f.fieldType == 'audio') return ' (audio)';
    if (f.fieldType == 'file' || f.hasFile) return ' (file)';
    return '';
  }

  Future<void> _showRequiredFieldsSheet(
      List<({int section, int field, String label})> missing) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist_rtl, color: Colors.orange, size: 22.sp),
                  SizedBox(width: 10.w),
                  Text('Almost done',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 4.w),
              Text(
                '${missing.length} required '
                '${missing.length == 1 ? "item" : "items"} left to complete',
                style: TextStyle(color: Colors.white60, fontSize: 13.sp),
              ),
              SizedBox(height: 12.w),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: missing.length,
                  separatorBuilder: (_, _) => Divider(
                      height: 1, color: Colors.white.withAlpha(15)),
                  itemBuilder: (_, idx) {
                    final m = missing[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.error_outline,
                          color: Colors.orange, size: 20.sp),
                      title: Text(m.label,
                          style: TextStyle(
                              color: Colors.white, fontSize: 14.sp)),
                      subtitle: Text('Section ${m.section + 1}',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11.sp)),
                      trailing: Icon(Icons.chevron_right,
                          color: Colors.white38, size: 20.sp),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpTo(m.section, m.field);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12.w),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InspectionColors.navBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _jumpTo(missing.first.section, missing.first.field);
                  },
                  icon: Icon(Icons.arrow_forward, size: 18.sp),
                  label: const Text('Go to first missing field'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- completion tracker ----------------------------------------------------

  /// Every required (or registration) field with its completion status, across
  /// all sections — backs the on-demand checklist overlay.
  List<({int section, int field, String label, bool done})> _requiredStatus(
      List<InspectionSection> sections, LocalInspection draft) {
    final out = <({int section, int field, String label, bool done})>[];
    for (var s = 0; s < sections.length; s++) {
      final fields = _fields(sections[s]);
      for (var i = 0; i < fields.length; i++) {
        final f = fields[i];
        if (!(f.isRequired || _isRegField(f))) continue;
        out.add((
          section: s,
          field: i,
          label: '${f.title ?? fieldKey(f)}${_missingTypeSuffix(f)}',
          done: _fieldProcessed(f, draft),
        ));
      }
    }
    return out;
  }

  /// On-demand checklist of all required fields with done/pending status, a
  /// progress bar, tap-to-jump, and a Submit shortcut once everything is done.
  Future<void> _showCompletionTracker() async {
    final draft = ref.read(inspectionSessionControllerProvider);
    if (draft?.inspectionTemplate == null) return;
    final template =
        InspectionInitializationResponse.fromJson(draft!.inspectionTemplate!);
    final items = _requiredStatus(_sections(template), draft);
    final doneCount = items.where((e) => e.done).length;
    final allDone = items.isEmpty || doneCount == items.length;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist_rtl,
                      color: allDone ? Colors.green : Colors.orange,
                      size: 22.sp),
                  SizedBox(width: 10.w),
                  Text('Required checklist',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 8.w),
              if (items.isEmpty)
                Text('No required fields — ready to submit.',
                    style: TextStyle(color: Colors.white60, fontSize: 13.sp))
              else ...[
                Text('$doneCount of ${items.length} required complete',
                    style:
                        TextStyle(color: Colors.white60, fontSize: 13.sp)),
                SizedBox(height: 8.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: doneCount / items.length,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: allDone ? Colors.green : InspectionColors.navBlue,
                  ),
                ),
                SizedBox(height: 12.w),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.white.withAlpha(15)),
                    itemBuilder: (_, idx) {
                      final m = items[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          m.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: m.done ? Colors.green : Colors.orange,
                          size: 20.sp,
                        ),
                        title: Text(m.label,
                            style: TextStyle(
                                color: m.done ? Colors.white54 : Colors.white,
                                fontSize: 14.sp)),
                        subtitle: Text('Section ${m.section + 1}',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11.sp)),
                        trailing: m.done
                            ? null
                            : Icon(Icons.chevron_right,
                                color: Colors.white38, size: 20.sp),
                        onTap: () {
                          Navigator.pop(ctx);
                          _jumpTo(m.section, m.field);
                        },
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: 12.w),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        allDone ? Colors.green : InspectionColors.navBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (allDone) {
                      _confirmSubmit();
                    } else {
                      final next = items.firstWhere((e) => !e.done);
                      _jumpTo(next.section, next.field);
                    }
                  },
                  icon: Icon(allDone ? Icons.check : Icons.arrow_forward,
                      size: 18.sp),
                  label: Text(
                      allDone ? 'Submit inspection' : 'Go to next required'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- progress -------------------------------------------------------------

  bool _fieldProcessed(InspectionField f, LocalInspection draft) {
    final key = fieldKey(f);
    if (f.fieldType == 'image' || f.hasImage || f.hasMultipleImages) {
      return draft.itemImages[key] != null ||
          (draft.itemMultiImages[key]?.isNotEmpty ?? false);
    }
    if (f.fieldType == 'video' || f.hasVideo) {
      return draft.itemVideos[key] != null;
    }
    if (f.fieldType == 'audio') return draft.itemAudios[key] != null;
    if (f.fieldType == 'file' || f.hasFile) return draft.itemFiles[key] != null;
    final v = draft.itemValues[key] ?? draft.textFieldValues[key];
    return v != null && v.isNotEmpty && v != 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(inspectionSessionControllerProvider);

    if (draft?.inspectionTemplate == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: _LoadingState(),
      );
    }

    final template =
        InspectionInitializationResponse.fromJson(draft!.inspectionTemplate!);
    final sections = _sections(template);
    if (sections.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _EmptyState(onBack: _leave),
      );
    }

    if (!_restored) {
      _restored = true;
      _sectionIndex = draft.currentSection.clamp(0, sections.length - 1);
    }

    final section = sections[_sectionIndex];
    final fields = _fields(section);
    final field = fields[_itemIndex.clamp(0, fields.length - 1)];
    final key = fieldKey(field);

    final totalFields = sections.fold<int>(0, (sum, s) => sum + s.fields.length);
    final processed = sections.fold<int>(
        0,
        (sum, s) =>
            sum + s.fields.where((f) => _fieldProcessed(f, draft)).length);
    final percent =
        totalFields == 0 ? 0 : (processed / totalFields * 100).round();
    final requiredLeft =
        _requiredStatus(sections, draft).where((e) => !e.done).length;
    final isLast = _sectionIndex == sections.length - 1 &&
        _itemIndex == fields.length - 1;
    final canPrev = _sectionIndex > 0 || _itemIndex > 0;
    final sectionName = section.name ?? section.title ?? '';

    final isMedia = _isMediaField(field);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: _buildAppBar(
          title: field.title ?? section.title ?? 'Inspection',
          subtitle: 'Field ${_itemIndex + 1} out ${fields.length} • '
              'Section ${_sectionIndex + 1}/${sections.length}',
          percent: percent,
          requiredLeft: requiredLeft,
        ),
        endDrawer: InspectionSectionsDrawer(
          sections: sections,
          draft: draft,
          activeSection: _sectionIndex,
          onSelectSection: (i) {
            Navigator.of(context).pop();
            _jumpTo(i, 0);
          },
          onSelectField: (s, f) {
            Navigator.of(context).pop();
            _jumpTo(s, f);
          },
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: totalFields == 0 ? 0 : processed / totalFields,
              minHeight: 3,
              backgroundColor: Colors.white12,
              color: InspectionColors.navBlue,
            ),
            Expanded(
              child: isMedia
                  ? _MediaFieldHud(
                      key: ValueKey('hud_$key'),
                      field: field,
                      sectionName: sectionName,
                      sectionTitle: section.title ?? sectionName,
                      draft: draft,
                    )
                  : SingleChildScrollView(
                      child: _FieldCard(
                        key: ValueKey('card_$key'),
                        field: field,
                        sectionName: sectionName,
                        sectionTitle: section.title ?? sectionName,
                        draft: draft,
                      ),
                    ),
            ),
            _buildNavBar(sections, canPrev: canPrev, isLast: isLast),
          ],
        ),
      ),
    );
  }

  bool _isMediaField(InspectionField f) =>
      const {'image', 'video', 'audio', 'file'}.contains(f.fieldType) ||
      f.hasImage ||
      f.hasVideo ||
      f.hasFile ||
      f.hasMultipleImages;

  PreferredSizeWidget _buildAppBar({
    required String title,
    required String subtitle,
    required int percent,
    required int requiredLeft,
  }) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              )),
          Text(subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
        ],
      ),
      actions: [
        // The "% Complete" text doubles as the required-checklist button (no
        // separate icon → saves app-bar width). Remaining required shows as a
        // small inline badge.
        Center(
          child: TextButton(
            onPressed: _showCompletionTracker,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$percent% Complete',
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
                if (requiredLeft > 0) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('$requiredLeft',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.white60, size: 22.sp),
          onPressed: _confirmStop,
        ),
        IconButton(
          icon: Icon(Icons.menu, color: Colors.white60, size: 22.sp),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildNavBar(List<InspectionSection> sections,
      {required bool canPrev, required bool isLast}) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 12.w),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canPrev ? () => _goPrev(sections) : null,
                  icon: Icon(Icons.arrow_back, size: 18.sp),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white30,
                    side: BorderSide(
                        color: canPrev ? Colors.white30 : Colors.white12),
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _goNext(sections),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(Icons.arrow_forward, size: 18.sp),
                  label: Text(isLast ? 'Finish' : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InspectionColors.navBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Loading / empty states
// ===========================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          SizedBox(height: 16.w),
          Text('Loading inspection template...',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.orange),
            SizedBox(height: 16.w),
            Text('Could not load inspection form',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8.w),
            Text('This template has no fields.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
            SizedBox(height: 16.w),
            TextButton(onPressed: onBack, child: const Text('Go back')),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Non-media field card (white card on black scaffold)
// ===========================================================================

class _FieldCard extends ConsumerWidget {
  const _FieldCard({
    super.key,
    required this.field,
    required this.sectionName,
    required this.sectionTitle,
    required this.draft,
  });

  final InspectionField field;
  final String sectionName;
  final String sectionTitle;
  final LocalInspection draft;

  Color get _typeColor => switch (field.fieldType) {
        'image' => InspectionColors.fieldImage,
        'video' => InspectionColors.fieldVideo,
        'dropdown' => InspectionColors.fieldDropdown,
        'file' => InspectionColors.fieldFile,
        'audio' => InspectionColors.fieldAudio,
        _ => Colors.grey,
      };

  IconData get _typeIcon => switch (field.fieldType) {
        'image' => Icons.image_outlined,
        'video' => Icons.videocam_outlined,
        'dropdown' => Icons.arrow_drop_down_circle_outlined,
        'file' => Icons.attach_file_outlined,
        'audio' => Icons.audiotrack_outlined,
        _ => Icons.text_fields_outlined,
      };

  bool get _isRegNo => (field.fieldId?.toLowerCase() ?? '') == 'regno';
  bool get _hasFlaggable =>
      field.options.isNotEmpty && !field.hasImage && !field.hasVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = fieldKey(field);
    final session = ref.read(inspectionSessionControllerProvider.notifier);
    final flagged =
        ref.watch(inspectionSessionControllerProvider.select((d) =>
            d?.itemFlaggedIssues[key] ?? const <String>[]));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10.r,
            offset: Offset(0, 4.w),
          ),
        ],
        border: Border.all(
          color: field.isRequired
              ? Colors.orange.withAlpha(128)
              : const Color(0xFFE4E7EB),
          width: field.isRequired ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _typeColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 15.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(field.title ?? key,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                )),
                          ),
                          if (field.isRequired)
                            Text(' *',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red)),
                        ],
                      ),
                      SizedBox(height: 2.w),
                      Text(field.fieldType,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11.sp)),
                    ],
                  ),
                ),
                if (field.referenceMedia.isNotEmpty || field.metadata != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                    iconSize: 22.sp,
                    icon: const Icon(Icons.info_outline,
                        color: InspectionColors.fieldImage),
                    onPressed: () => FieldInfoSheet.show(context, field),
                  ),
                if (_hasFlaggable)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        BoxConstraints(minWidth: 36.w, minHeight: 36.w),
                    iconSize: 22.sp,
                    icon: Icon(
                        flagged.isNotEmpty ? Icons.flag : Icons.flag_outlined,
                        color: flagged.isNotEmpty
                            ? Colors.orange
                            : Colors.grey[500]),
                    onPressed: () => _openFlagSheet(context, ref),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.w),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildControl(context, ref, key, session),
                if (flagged.isNotEmpty) ...[
                  SizedBox(height: 12.w),
                  _FlagChipsWrap(issues: flagged),
                ],
                if (field.hasRemarks) ...[
                  SizedBox(height: 12.w),
                  Text('Remarks',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                  SizedBox(height: 6.w),
                  _LightTextField(
                    initial: draft.itemRemarks[key],
                    hint: 'Add remarks...',
                    minLines: 2,
                    maxLines: null,
                    onChanged: (v) => session.setRemark(key, v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControl(BuildContext context, WidgetRef ref, String key,
      InspectionSessionController session) {
    if (_isRegNo) {
      return _RegnoInput(
        initial: draft.itemValues[key] ?? draft.textFieldValues[key],
        onChanged: (v) => session.setValue(key, v),
      );
    }
    if (field.options.isNotEmpty && field.fieldType == 'dropdown') {
      final value = draft.itemValues[key];
      return DropdownButtonFormField<String>(
        initialValue: (value == null || value == 'N/A') ? null : value,
        isExpanded: true,
        decoration: _lightDecoration(context).copyWith(
          hintText: 'Select an option',
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
        ),
        hint: const Text('Select an option'),
        items: [
          for (final o in field.options)
            DropdownMenuItem(
              value: o.value,
              child: Text(o.label ?? o.value ?? ''),
            ),
        ],
        onChanged: (v) => v == null ? null : session.setValue(key, v),
      );
    }
    return _LightTextField(
      initial: draft.itemValues[key] ?? draft.textFieldValues[key],
      hint: field.fieldType == 'date' ? 'YYYY-MM-DD' : 'Enter details...',
      minLines: 1,
      maxLines: 1,
      onChanged: (v) => session.setValue(key, v),
    );
  }

  Future<void> _openFlagSheet(BuildContext context, WidgetRef ref) async {
    final key = fieldKey(field);
    final session = ref.read(inspectionSessionControllerProvider.notifier);
    final draftNow = ref.read(inspectionSessionControllerProvider);
    final result = await InspectionFlagIssuesSheet.show(
      context,
      sectionTitle: sectionTitle,
      field: field,
      initialIssues: draftNow?.itemFlaggedIssues[key] ?? const [],
      initialNotes: draftNow?.itemRemarks[key] ?? '',
    );
    if (result == null) return;
    session.setFlagged(key, result.issues);
    if (field.fieldType != 'dropdown') {
      session.setValue(key, result.markedNoIssues ? 'no_issues' : 'flagged');
    }
    if (result.notes.isNotEmpty) session.setRemark(key, result.notes);
  }
}

InputDecoration _lightDecoration(BuildContext context) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[50],
    hintStyle:
        TextStyle(color: Colors.grey.withAlpha(153), fontSize: 14.sp),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: Colors.grey.withAlpha(128)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
    ),
  );
}

/// Flag chips shown below controls when issues are flagged.
class _FlagChipsWrap extends StatelessWidget {
  const _FlagChipsWrap({required this.issues});
  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.w,
      children: [
        for (final issue in issues)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange.withAlpha(128)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag, size: 11.sp, color: Colors.orange),
                SizedBox(width: 4.w),
                Text(issue,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LightTextField extends StatefulWidget {
  const _LightTextField({
    required this.initial,
    required this.hint,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String? initial;
  final String hint;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;

  @override
  State<_LightTextField> createState() => _LightTextFieldState();
}

class _LightTextFieldState extends State<_LightTextField> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      keyboardType: TextInputType.multiline,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      decoration: _lightDecoration(context).copyWith(hintText: widget.hint),
    );
  }
}

/// Registration-number field with a Verify action + RC details card.
class _RegnoInput extends ConsumerStatefulWidget {
  const _RegnoInput({required this.initial, required this.onChanged});
  final String? initial;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_RegnoInput> createState() => _RegnoInputState();
}

class _RegnoInputState extends ConsumerState<_RegnoInput> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);
  bool _verifying = false;
  String? _resultBody;
  bool _resultOk = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final value = _c.text.trim();
    if (value.isEmpty) return;
    setState(() => _verifying = true);
    final res =
        await ref.read(inspectionRepositoryProvider).verifyRegistration(value);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      switch (res) {
        case ApiSuccess(:final data):
          _resultOk = true;
          _resultBody = data.entries
              .take(25)
              .map((e) => '${e.key}: ${e.value}')
              .join('\n');
        case ApiNetworkError():
          _resultOk = false;
          _resultBody = 'No connection. Check your network.';
        default:
          _resultOk = false;
          _resultBody = 'Could not verify this registration number.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _c,
                textCapitalization: TextCapitalization.characters,
                onChanged: widget.onChanged,
                decoration: _lightDecoration(context)
                    .copyWith(hintText: 'e.g. MH12AB1234'),
              ),
            ),
            SizedBox(width: 8.w),
            _verifying
                ? SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: Center(
                      child: SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: primary),
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: _verify,
                    child: const Text('Verify'),
                  ),
          ],
        ),
        if (_resultBody != null) ...[
          SizedBox(height: 12.w),
          _RegnoResultCard(
            ok: _resultOk,
            body: _resultBody!,
            onClose: () => setState(() => _resultBody = null),
          ),
        ],
      ],
    );
  }
}

class _RegnoResultCard extends StatelessWidget {
  const _RegnoResultCard({
    required this.ok,
    required this.body,
    required this.onClose,
  });

  final bool ok;
  final String body;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final accent = ok ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.error;
    return Material(
      borderRadius: BorderRadius.circular(12.r),
      color: accent.withAlpha(20),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.verified : Icons.error_outline,
                    color: accent, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(ok ? 'Verified — RC details' : 'Verification failed',
                      style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp)),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
                  iconSize: 18.sp,
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            SizedBox(height: 6.w),
            SelectableText(body,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Media field — full dark camera HUD
// ===========================================================================

class _MediaFieldHud extends ConsumerStatefulWidget {
  const _MediaFieldHud({
    super.key,
    required this.field,
    required this.sectionName,
    required this.sectionTitle,
    required this.draft,
  });

  final InspectionField field;
  final String sectionName;
  final String sectionTitle;
  final LocalInspection draft;

  @override
  ConsumerState<_MediaFieldHud> createState() => _MediaFieldHudState();
}

class _MediaFieldHudState extends ConsumerState<_MediaFieldHud> {
  late CaptureMode _mode;
  bool _flashOn = false;
  bool _highlightFlag = false;

  // Set once the embedded live camera is ready; the bottom-panel shutter/flash/
  // record buttons drive the live preview through these instead of launching a
  // separate route.
  VoidCallback? _captureTrigger;
  VoidCallback? _flashTrigger;
  VoidCallback? _recordTrigger;
  bool _videoRecording = false;
  Duration _videoElapsed = Duration.zero;

  // audio recording state
  final _recorder = AudioRecorder();
  bool _recordingAudio = false;
  Duration _audioElapsed = Duration.zero;
  Timer? _audioTimer;
  String? _audioPath;

  bool get _isMulti =>
      widget.field.hasMultipleImages ||
      (widget.field.fieldType == 'text' && widget.field.hasImage);

  @override
  void initState() {
    super.initState();
    _mode = _defaultMode();
  }

  CaptureMode _defaultMode() {
    final f = widget.field;
    if (f.fieldType == 'video' || f.hasVideo) return CaptureMode.video;
    if (f.fieldType == 'audio') return CaptureMode.audio;
    if (f.fieldType == 'file' || f.hasFile) return CaptureMode.file;
    return CaptureMode.photo;
  }

  // Like the old app, every media field can switch to any capture type — the
  // inspector chooses photo/video/file/audio freely. [_defaultMode] just picks
  // the sensible starting tab from the field's declared type.
  static const Set<CaptureMode> _available = {
    CaptureMode.file,
    CaptureMode.photo,
    CaptureMode.video,
    CaptureMode.audio,
  };

  @override
  void dispose() {
    _audioTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String get _key => fieldKey(widget.field);
  MediaCaptureController get _capture =>
      ref.read(mediaCaptureControllerProvider.notifier);
  InspectionSessionController get _session =>
      ref.read(inspectionSessionControllerProvider.notifier);

  // --- capture handlers -----------------------------------------------------

  Future<void> _launchPhotoCamera() async {
    final file = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenCamera(
          instruction: widget.field.title,
          flashOn: _flashOn,
        ),
      ),
    );
    if (file == null || !mounted) return;
    if (_isMulti) {
      await _capture.addImageToMulti(
          key: _key, section: widget.sectionName, rawPath: file.path);
    } else {
      await _capture.captureImage(
          key: _key, section: widget.sectionName, savedOrRawPath: file.path);
    }
  }

  /// Live in-HUD viewfinder (camera on). The bottom-panel shutter/flash drive it
  /// via [_captureTrigger]/[_flashTrigger] set on init — matching the old app's
  /// embedded camera, instead of pushing a separate full-screen route.
  Widget _buildLiveCamera({required void Function(XFile file) onCapture}) {
    return SectionCameraCard(
      showControls: false,
      onCapture: onCapture,
      onCaptureReady: (fn) {
        if (mounted) setState(() => _captureTrigger = fn);
      },
      onFlashReady: (fn) {
        if (mounted) setState(() => _flashTrigger = fn);
      },
      onFlashModeChanged: (on) {
        if (mounted) setState(() => _flashOn = on);
      },
    );
  }

  /// Live in-HUD video viewfinder (camera on). The bottom-panel record/flash
  /// buttons drive it via [_recordTrigger]/[_flashTrigger]; on stop the video is
  /// emitted straight to the draft, like the photo flow.
  Widget _buildLiveVideoCamera() {
    return SectionVideoCameraCard(
      showControls: false,
      onCaptured: (file) => _capture.captureVideo(
          key: _key, section: widget.sectionName, rawPath: file.path),
      onRecordReady: (fn) {
        if (mounted) setState(() => _recordTrigger = fn);
      },
      onFlashReady: (fn) {
        if (mounted) setState(() => _flashTrigger = fn);
      },
      onFlashModeChanged: (on) {
        if (mounted) setState(() => _flashOn = on);
      },
      onRecordingChanged: (recording, elapsed) {
        if (mounted) {
          setState(() {
            _videoRecording = recording;
            _videoElapsed = elapsed;
          });
        }
      },
    );
  }

  void _onPhotoShutter() {
    final trigger = _captureTrigger;
    if (trigger != null) {
      trigger();
    } else {
      _launchPhotoCamera(); // fallback (e.g. adding to a multi-image grid)
    }
  }

  void _onVideoRecord() {
    final trigger = _recordTrigger;
    if (trigger != null) {
      trigger();
    } else {
      _launchVideoCamera(); // fallback if the live camera failed to start
    }
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onFlashToggle() {
    final trigger = _flashTrigger;
    if (trigger != null) {
      trigger();
    } else {
      setState(() => _flashOn = !_flashOn);
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    if (_isMulti) {
      await _capture.addImageToMulti(
          key: _key, section: widget.sectionName, rawPath: picked.path);
    } else {
      await _capture.captureImage(
          key: _key, section: widget.sectionName, savedOrRawPath: picked.path);
    }
  }

  Future<void> _launchVideoCamera() async {
    final file = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenVideoCamera(
          instruction: widget.field.title,
        ),
      ),
    );
    if (file == null || !mounted) return;
    await _capture.captureVideo(
        key: _key, section: widget.sectionName, rawPath: file.path);
  }

  Future<void> _pickVideoFromGallery() async {
    final picked =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    await _capture.captureVideo(
        key: _key, section: widget.sectionName, rawPath: picked.path);
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.pickFile();
    final p = res?.path;
    if (p == null || !mounted) return;
    await _capture.captureFile(
        key: _key, section: widget.sectionName, rawPath: p);
  }

  Future<void> _browseAudio() async {
    final res = await FilePicker.pickFile(type: FileType.audio);
    final p = res?.path;
    if (p == null || !mounted) return;
    await _capture.captureAudio(
        key: _key, section: widget.sectionName, rawPath: p);
  }

  Future<void> _toggleAudio() async {
    if (_recordingAudio) {
      _audioTimer?.cancel();
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() => _recordingAudio = false);
      final p = path ?? _audioPath;
      if (p != null) {
        await _capture.captureAudio(
            key: _key, section: widget.sectionName, rawPath: p);
      }
    } else {
      if (!await _recorder.hasPermission()) return;
      final dir = await getTemporaryDirectory();
      _audioPath = '${dir.path}/${const Uuid().v4()}.m4a';
      await _recorder.start(const RecordConfig(), path: _audioPath!);
      if (!mounted) return;
      setState(() {
        _recordingAudio = true;
        _audioElapsed = Duration.zero;
      });
      _audioTimer = Timer.periodic(const Duration(seconds: 1),
          (_) => setState(() => _audioElapsed += const Duration(seconds: 1)));
    }
  }

  Future<void> _openFlagSheet() async {
    final draftNow = ref.read(inspectionSessionControllerProvider);
    final result = await InspectionFlagIssuesSheet.show(
      context,
      sectionTitle: widget.sectionTitle,
      field: widget.field,
      initialIssues: draftNow?.itemFlaggedIssues[_key] ?? const [],
      initialNotes: draftNow?.itemRemarks[_key] ?? '',
    );
    if (result == null) return;
    _session.setFlagged(_key, result.issues);
    if (widget.field.fieldType != 'dropdown') {
      _session.setValue(_key, result.markedNoIssues ? 'no_issues' : 'flagged');
    }
    if (result.notes.isNotEmpty) _session.setRemark(_key, result.notes);
    if (mounted) setState(() => _highlightFlag = false);
  }

  // --- state lookups --------------------------------------------------------

  bool get _hasMedia {
    final d = ref.read(inspectionSessionControllerProvider);
    switch (_mode) {
      case CaptureMode.photo:
        return _isMulti
            ? (d?.itemMultiImages[_key]?.isNotEmpty ?? false)
            : d?.itemImages[_key] != null;
      case CaptureMode.video:
        return d?.itemVideos[_key] != null;
      case CaptureMode.audio:
        return d?.itemAudios[_key] != null;
      case CaptureMode.file:
        return d?.itemFiles[_key] != null;
    }
  }

  String? get _refUrl {
    if (widget.field.referenceMedia.isEmpty) return null;
    final r = widget.field.referenceMedia.first;
    return r.url ?? r.filePath;
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(inspectionSessionControllerProvider);
    final busy =
        ref.watch(mediaCaptureControllerProvider.select((m) => m[_key] ?? false));
    final flagged = draft?.itemFlaggedIssues[_key] ?? const <String>[];
    final value = draft?.itemValues[_key];
    final markedNoIssues = value == 'no_issues';
    final hasMedia = _hasMedia;
    final showCameraRow = !hasMedia && !busy;

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCaptureArea(draft, busy),
              if (_refUrl != null &&
                  (_mode == CaptureMode.photo || _mode == CaptureMode.video))
                ReferenceThumbnail(
                  url: _refUrl!,
                  isVideo:
                      widget.field.referenceMedia.first.mediaType == 'video',
                  onTap: () => _showFullscreenRef(_refUrl!),
                ),
              if (_mode == CaptureMode.photo && !_isMulti && hasMedia)
                HudPillBadge(
                  border: Colors.white30,
                  onTap: _launchPhotoCamera,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text('Retake',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              if (_mode == CaptureMode.file && hasMedia)
                HudPillBadge(
                  border: Colors.white30,
                  onTap: _pickFile,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text('Replace',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              if (_mode == CaptureMode.video && _videoRecording)
                HudPillBadge(
                  border: Colors.red,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6.w),
                      Text('REC ${_fmtDuration(_videoElapsed)}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              // Re-record: discard captured video/audio so the live
              // camera/recorder returns for the field.
              if ((_mode == CaptureMode.video || _mode == CaptureMode.audio) &&
                  hasMedia)
                HudPillBadge(
                  border: Colors.white30,
                  onTap: () => _mode == CaptureMode.video
                      ? _session.removeVideo(_key)
                      : _session.removeAudio(_key),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text('Re-record',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ConditionFlagRow(
                flaggedCount: flagged.length,
                markedNoIssues: markedNoIssues,
                highlightFlag: _highlightFlag,
                onTapCondition: _openFlagSheet,
                onTapFlag: () {
                  setState(() => _highlightFlag = false);
                  _openFlagSheet();
                },
              ),
            ],
          ),
        ),
        _buildBottomPanel(showCameraRow: showCameraRow),
      ],
    );
  }

  Widget _buildCaptureArea(LocalInspection? draft, bool busy) {
    if (busy) {
      return Container(
        color: const Color(0xFF111111),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white70),
      );
    }
    switch (_mode) {
      case CaptureMode.photo:
        if (_isMulti) {
          return _buildMultiPreview(draft);
        }
        final p = draft?.itemImages[_key];
        if (p != null) {
          return CapturedMediaPreview(
            mode: CaptureMode.photo,
            imagePath: p,
            onTapImage: () =>
                _showFullscreenImage(p, onDelete: () => _session.removeImage(_key)),
          );
        }
        return _buildLiveCamera(
          onCapture: (file) => _capture.captureImage(
              key: _key, section: widget.sectionName, savedOrRawPath: file.path),
        );
      case CaptureMode.video:
        final v = draft?.itemVideos[_key];
        if (v != null) {
          return CapturedMediaPreview(
            mode: CaptureMode.video,
            videoPath: v,
            onTapVideo: () => _showFullscreenVideo(v),
          );
        }
        return _buildLiveVideoCamera();
      case CaptureMode.file:
        final f = draft?.itemFiles[_key];
        if (f != null) {
          return CapturedMediaPreview(
              mode: CaptureMode.file, fileName: f.split('/').last);
        }
        return CaptureEmptyState(
          icon: Icons.attach_file,
          onTap: _pickFile,
        );
      case CaptureMode.audio:
        if (draft?.itemAudios[_key] != null) {
          return const CapturedMediaPreview(mode: CaptureMode.audio);
        }
        if (_recordingAudio) {
          return _buildAudioRecording();
        }
        return CaptureEmptyState(
          icon: Icons.mic_outlined,
          browseLabel: 'Browse audio files',
          onBrowse: _browseAudio,
        );
    }
  }

  Widget _buildMultiPreview(LocalInspection? draft) {
    final images = draft?.itemMultiImages[_key] ?? const [];
    return Container(
      color: const Color(0xFF111111),
      child: images.isEmpty
          ? _buildLiveCamera(
              onCapture: (file) => _capture.addImageToMulti(
                  key: _key, section: widget.sectionName, rawPath: file.path),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(12.w, 50.w, 12.w, 56.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photos (${images.length}/$_maxMultiImages)',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13.sp)),
                    SizedBox(height: 8.w),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.w,
                      children: [
                        for (var i = 0; i < images.length; i++)
                          _MultiThumb(
                            path: images[i],
                            onTap: () => _showFullscreenImage(images[i],
                                onDelete: () =>
                                    _session.removeMultiImageAt(_key, i)),
                            onRemove: () => _session.removeMultiImageAt(_key, i),
                          ),
                        if (images.length < _maxMultiImages)
                          GestureDetector(
                            onTap: _launchPhotoCamera,
                            child: Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.white30),
                                color: Colors.white.withAlpha(10),
                              ),
                              child: Icon(Icons.add_a_photo_outlined,
                                  color: Colors.white60, size: 24.sp),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAudioRecording() {
    final mm = _audioElapsed.inMinutes.toString().padLeft(2, '0');
    final ss = (_audioElapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Container(
      color: const Color(0xFF111111),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withAlpha(38),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Icon(Icons.mic, color: Colors.red, size: 32.sp),
          ),
          SizedBox(height: 20.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Colors.red, size: 8.sp),
              SizedBox(width: 8.w),
              Text('$mm:$ss',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
          SizedBox(height: 10.w),
          Text('Recording...',
              style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildBottomPanel({required bool showCameraRow}) {
    final title = widget.field.title ?? 'this item';
    final instruction = switch (_mode) {
      CaptureMode.video => 'Record a video of: $title',
      CaptureMode.file => 'Attach a document for: $title',
      CaptureMode.audio => 'Add an audio note for: $title',
      CaptureMode.photo => 'Take a clear photo of: $title',
    };
    return Container(
      color: InspectionColors.panel,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instruction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 8.w),
              CaptureModeTabs(
                current: _mode,
                available: _available,
                onChanged: (m) => setState(() {
                  _mode = m;
                  _flashOn = false;
                  // Triggers belong to the viewfinder being torn down.
                  _captureTrigger = null;
                  _flashTrigger = null;
                  _recordTrigger = null;
                  _videoRecording = false;
                  _videoElapsed = Duration.zero;
                }),
              ),
              if (showCameraRow) ...[
                SizedBox(height: 12.w),
                _buildActionRow(),
                SizedBox(height: 12.w),
              ] else
                SizedBox(height: 10.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    final isPhotoOrVideo =
        _mode == CaptureMode.photo || _mode == CaptureMode.video;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isPhotoOrVideo)
          HudSideButton(
            icon: _mode == CaptureMode.video
                ? Icons.video_library_outlined
                : Icons.photo_library_outlined,
            enabled: !_videoRecording,
            onTap: _videoRecording
                ? null
                : (_mode == CaptureMode.video
                    ? _pickVideoFromGallery
                    : _pickPhotoFromGallery),
          )
        else
          SizedBox(width: 46.w, height: 46.w),
        _buildMainAction(),
        if (isPhotoOrVideo)
          HudSideButton(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            active: _flashOn,
            onTap: _onFlashToggle,
          )
        else
          SizedBox(width: 46.w, height: 46.w),
      ],
    );
  }

  Widget _buildMainAction() {
    switch (_mode) {
      case CaptureMode.photo:
        return ShutterButton(onTap: _onPhotoShutter);
      case CaptureMode.video:
        return RecordButton(recording: _videoRecording, onTap: _onVideoRecord);
      case CaptureMode.file:
        return HudRoundActionButton(
          icon: Icons.attach_file,
          fill: InspectionColors.shutterBlue.withAlpha(38),
          border: InspectionColors.shutterBlue,
          iconColor: InspectionColors.shutterBlue,
          onTap: _pickFile,
        );
      case CaptureMode.audio:
        return HudRoundActionButton(
          icon: _recordingAudio ? Icons.stop : Icons.mic,
          fill: _recordingAudio
              ? Colors.red.withAlpha(38)
              : InspectionColors.audioPink.withAlpha(38),
          border: _recordingAudio ? Colors.red : InspectionColors.audioPink,
          iconColor: _recordingAudio ? Colors.red : InspectionColors.audioPink,
          onTap: _toggleAudio,
        );
    }
  }

  void _showFullscreenImage(String path, {VoidCallback? onDelete}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: path.startsWith('http')
                ? Image.network(path)
                : Image.file(File(path)),
          ),
        ),
      ),
    ));
  }

  void _showFullscreenVideo(String path) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => VideoPreviewScreen(path: path),
    ));
  }

  void _showFullscreenRef(String url) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(child: CachedReferenceImage(url)),
      ),
    ));
  }
}

// ===========================================================================
// Full-screen camera launch wrappers (reuse the self-contained cards)
// ===========================================================================

/// A multi-image grid thumbnail with a tap-to-preview and a remove (X) badge.
class _MultiThumb extends StatelessWidget {
  const _MultiThumb({
    required this.path,
    required this.onTap,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: path.startsWith('http')
                ? Image.network(path,
                    width: 70.w, height: 70.w, fit: BoxFit.cover)
                : Image.file(File(path),
                    width: 70.w, height: 70.w, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6.w,
          right: -6.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 13.sp),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenCamera extends StatelessWidget {
  const _FullScreenCamera({this.instruction, this.flashOn = false});
  final String? instruction;
  final bool flashOn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SectionCameraCard(
          height: MediaQuery.sizeOf(context).height,
          instructionText: instruction,
          onPickFromGallery: () async {
            final picked =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (picked != null && context.mounted) {
              Navigator.of(context).pop(picked);
            }
          },
          onCapture: (f) => Navigator.of(context).pop(f),
        ),
      ),
    );
  }
}

class _FullScreenVideoCamera extends StatelessWidget {
  const _FullScreenVideoCamera({this.instruction});
  final String? instruction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SectionVideoCameraCard(
          height: MediaQuery.sizeOf(context).height,
          instructionText: instruction,
          onCaptured: (f) => Navigator.of(context).pop(f),
        ),
      ),
    );
  }
}

/// Blocking sheet shown at submit while captured photos finish uploading. It
/// cannot be dismissed (back button / drag / tap-outside) so the user can't
/// submit past an in-flight upload; the submit flow pops it once uploads settle.
class _UploadWaitSheet extends ConsumerWidget {
  const _UploadWaitSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(mediaCaptureControllerProvider);
    final count = busy.values.where((b) => b).length;
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42.w,
                height: 42.w,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: scheme.primary),
              ),
              SizedBox(height: 18.h),
              Text(
                'Finishing photo uploads',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface),
              ),
              SizedBox(height: 6.h),
              Text(
                count > 0
                    ? 'Please wait — $count ${count == 1 ? 'upload is' : 'uploads are'} '
                        'still in progress. Keep the app open.'
                    : 'Almost done…',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.35,
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
