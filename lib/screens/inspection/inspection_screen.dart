import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_session_controller.dart';
import '../../controllers/inspection_submit_controller.dart';
import '../../data/inspection_submission_builder.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../models/inspection_template_model.dart';
import '../../models/local_inspection.dart';
import '../../services/api/api_result.dart';
import 'inspection_success_screen.dart';
import 'widgets/field_info_sheet.dart';
import 'widgets/media_field_control.dart';

class InspectionScreen extends ConsumerStatefulWidget {
  const InspectionScreen({super.key});

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  int _sectionIndex = 0;
  int _itemIndex = 0;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(inspectionSessionControllerProvider) == null) {
        ref.read(inspectionSessionControllerProvider.notifier).resumeDraft();
      }
    });
  }

  List<InspectionSection> _sections(InspectionInitializationResponse t) =>
      [...t.structure.sections]..sort((a, b) => a.order.compareTo(b.order));

  List<InspectionField> _fields(InspectionSection s) =>
      [...s.fields]..sort((a, b) => a.order.compareTo(b.order));

  void _goNext(List<InspectionSection> sections) {
    final fields = _fields(sections[_sectionIndex]);
    if (_itemIndex < fields.length - 1) {
      setState(() => _itemIndex++);
    } else if (_sectionIndex < sections.length - 1) {
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
      setState(() {
        _sectionIndex--;
        _itemIndex = _fields(sections[_sectionIndex]).length - 1;
      });
      ref
          .read(inspectionSessionControllerProvider.notifier)
          .setSection(_sectionIndex);
    }
  }

  Future<void> _confirmSubmit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit inspection?'),
        content: const Text('Review complete. Submit this inspection now?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );
    if (!(ok ?? false)) return;

    final outcome =
        await ref.read(inspectionSubmitControllerProvider.notifier).submit();
    if (!mounted) return;
    if (outcome.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(outcome.error!)));
      return;
    }
    context.goNamed(
      RouteNames.inspectionSuccess,
      extra: InspectionSuccessArgs(outcome: outcome),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(inspectionSessionControllerProvider);
    final submitting =
        ref.watch(inspectionSubmitControllerProvider).isSubmitting;

    if (draft?.inspectionTemplate == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspection')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final template =
        InspectionInitializationResponse.fromJson(draft!.inspectionTemplate!);
    final sections = _sections(template);
    if (sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspection')),
        body: const Center(child: Text('This template has no fields.')),
      );
    }

    // Restore last section once.
    if (!_restored) {
      _restored = true;
      _sectionIndex = draft.currentSection.clamp(0, sections.length - 1);
    }

    final section = sections[_sectionIndex];
    final fields = _fields(section);
    final field = fields[_itemIndex.clamp(0, fields.length - 1)];

    final totalFields = sections.fold<int>(0, (sum, s) => sum + s.fields.length);
    final doneBefore = sections
        .take(_sectionIndex)
        .fold<int>(0, (sum, s) => sum + s.fields.length);
    final globalIndex = doneBefore + _itemIndex + 1;
    final isLast = _sectionIndex == sections.length - 1 &&
        _itemIndex == fields.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(section.title ?? section.name ?? 'Inspection'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.w),
          child: LinearProgressIndicator(
            value: totalFields == 0 ? 0 : globalIndex / totalFields,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Field $globalIndex of $totalFields  •  '
              'Section ${_sectionIndex + 1}/${sections.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16.w),
            Expanded(
              child: SingleChildScrollView(
                child: _FieldControl(
                  key: ValueKey(fieldKey(field)),
                  field: field,
                  sectionName: section.name ?? section.title ?? '',
                  draft: draft,
                ),
              ),
            ),
            Row(
              children: [
                if (_sectionIndex > 0 || _itemIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          submitting ? null : () => _goPrev(sections),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_sectionIndex > 0 || _itemIndex > 0) SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitting ? null : () => _goNext(sections),
                    child: submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isLast ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the control for a single field. Text/date/dropdown + remarks.
/// Media fields show a placeholder until P6c wires capture.
class _FieldControl extends ConsumerWidget {
  const _FieldControl({
    super.key,
    required this.field,
    required this.sectionName,
    required this.draft,
  });

  final InspectionField field;
  final String sectionName;
  final LocalInspection draft;

  bool get _isMedia =>
      const {'image', 'video', 'audio', 'file'}.contains(field.fieldType) ||
      field.hasImage ||
      field.hasVideo ||
      field.hasFile ||
      field.hasMultipleImages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final key = fieldKey(field);
    final session = ref.read(inspectionSessionControllerProvider.notifier);

    final hasInfo = field.referenceMedia.isNotEmpty || field.metadata != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(field.title ?? key,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (hasInfo)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => FieldInfoSheet.show(context, field),
              ),
          ],
        ),
        if (field.isRequired)
          Text('Required', style: TextStyle(color: theme.colorScheme.error, fontSize: 12.sp)),
        SizedBox(height: 16.w),
        if (_isMedia)
          MediaFieldControl(
              field: field, sectionName: sectionName, draft: draft)
        else if (field.options.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: draft.itemValues[key],
            decoration: const InputDecoration(labelText: 'Select'),
            items: field.options
                .map((o) => DropdownMenuItem(
                      value: o.value,
                      child: Text(o.label ?? o.value ?? ''),
                    ))
                .toList(),
            onChanged: (v) => v == null ? null : session.setValue(key, v),
          )
        else if (field.fieldId == 'regno')
          _RegnoInput(
            initial: draft.itemValues[key] ?? draft.textFieldValues[key],
            onChanged: (v) => session.setValue(key, v),
          )
        else
          _TextInput(
            initial: draft.itemValues[key] ?? draft.textFieldValues[key],
            hint: field.fieldType == 'date' ? 'YYYY-MM-DD' : 'Enter value',
            onChanged: (v) => session.setValue(key, v),
          ),
        if (_isMedia && field.options.isNotEmpty) ...[
          SizedBox(height: 16.w),
          _FlagChips(field: field, fieldKeyStr: key),
        ],
        if (field.hasRemarks) ...[
          SizedBox(height: 16.w),
          Text('Remarks', style: theme.textTheme.bodyMedium),
          SizedBox(height: 8.w),
          _TextInput(
            initial: draft.itemRemarks[key],
            hint: 'Add remarks (optional)',
            maxLines: 3,
            onChanged: (v) => session.setRemark(key, v),
          ),
        ],
      ],
    );
  }
}

/// Registration-number field with an ULIP "Verify" action.
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
    setState(() => _verifying = false);
    final body = switch (res) {
      ApiSuccess(:final data) => data.entries
          .take(25)
          .map((e) => '${e.key}: ${e.value}')
          .join('\n'),
      ApiNetworkError() => 'No connection. Check your network.',
      _ => 'Could not verify this registration number.',
    };
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RC Details'),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _c,
          textCapitalization: TextCapitalization.characters,
          onChanged: widget.onChanged,
          decoration: const InputDecoration(hintText: 'Registration number'),
        ),
        SizedBox(height: 8.w),
        TextButton.icon(
          onPressed: _verifying ? null : _verify,
          icon: _verifying
              ? const SizedBox(
                  height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.verified_outlined),
          label: const Text('Verify'),
        ),
      ],
    );
  }
}

/// Condition-flag selector for media fields (from the field's options).
class _FlagChips extends ConsumerWidget {
  const _FlagChips({required this.field, required this.fieldKeyStr});
  final InspectionField field;
  final String fieldKeyStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(inspectionSessionControllerProvider
        .select((d) => d?.itemFlaggedIssues[fieldKeyStr] ?? const <String>[]));
    final session = ref.read(inspectionSessionControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Flag issues', style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 8.w),
        Wrap(
          spacing: 8.w,
          children: [
            for (final o in field.options)
              FilterChip(
                label: Text(o.label ?? o.value ?? ''),
                selected: current.contains(o.value),
                onSelected: (sel) {
                  final val = o.value ?? '';
                  final next = [...current];
                  if (sel) {
                    if (!next.contains(val)) next.add(val);
                  } else {
                    next.remove(val);
                  }
                  session.setFlagged(fieldKeyStr, next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _TextInput extends StatefulWidget {
  const _TextInput({
    required this.initial,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String? initial;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
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
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      decoration: InputDecoration(hintText: widget.hint),
    );
  }
}
