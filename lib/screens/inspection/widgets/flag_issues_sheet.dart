import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/inspection_template_model.dart';
import '../../../themes/inspection_colors.dart';

/// Outcome of the flag-issues sheet. [markedNoIssues] means the user confirmed
/// "no issues"; otherwise [issues] holds the single selected condition.
class FlagIssuesResult {
  const FlagIssuesResult({
    required this.markedNoIssues,
    required this.issues,
    required this.notes,
  });

  final bool markedNoIssues;
  final List<String> issues;
  final String notes;
}

/// Dark modal sheet for flagging an issue on a media/option field. Matches
/// formUi.md "Flag-issues sheet". Returns a [FlagIssuesResult] on confirm.
class InspectionFlagIssuesSheet extends StatefulWidget {
  const InspectionFlagIssuesSheet({
    super.key,
    required this.sectionTitle,
    required this.field,
    required this.initialIssues,
    required this.initialNotes,
  });

  final String sectionTitle;
  final InspectionField field;
  final List<String> initialIssues;
  final String initialNotes;

  /// Shows the sheet and returns the confirmed result (or null if dismissed).
  static Future<FlagIssuesResult?> show(
    BuildContext context, {
    required String sectionTitle,
    required InspectionField field,
    required List<String> initialIssues,
    required String initialNotes,
  }) {
    return showModalBottomSheet<FlagIssuesResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: InspectionFlagIssuesSheet(
          sectionTitle: sectionTitle,
          field: field,
          initialIssues: initialIssues,
          initialNotes: initialNotes,
        ),
      ),
    );
  }

  @override
  State<InspectionFlagIssuesSheet> createState() =>
      _InspectionFlagIssuesSheetState();
}

class _InspectionFlagIssuesSheetState extends State<InspectionFlagIssuesSheet> {
  String? _selected;
  late final TextEditingController _notes =
      TextEditingController(text: widget.initialNotes);

  @override
  void initState() {
    super.initState();
    _selected =
        widget.initialIssues.isNotEmpty ? widget.initialIssues.first : null;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Color _issueColor(DropdownOption o) {
    final code = o.colorCode;
    if (code.startsWith('#') && (code.length == 7 || code.length == 9)) {
      final hex = code.substring(1);
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(hex.length == 6 ? 0xFF000000 | value : value);
      }
    }
    return InspectionColors.shutterBlue;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.field.options;
    final hasSelection = _selected != null;

    return Container(
      decoration: const BoxDecoration(
        color: InspectionColors.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.w, bottom: 8.w),
                  width: 40.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.w, 12.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sectionTitle.toUpperCase(),
                            style: TextStyle(
                              color: InspectionColors.shutterBlue,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.w),
                          Text(
                            'Flag any issues',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        width: 28.w,
                        height: 28.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(Icons.close,
                            color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ],
                ),
              ),
              if (options.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 8.w),
                  child: Text(
                    'TAP TO ADD',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: [
                    for (final o in options) _chip(o),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
                child: Text(
                  'NOTES (OPTIONAL)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(18),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _notes,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note about what you noticed...',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontSize: 13.sp),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(14.w, 12.w, 8.w, 12.w),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.w,
                  child: hasSelection
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () => Navigator.of(context).pop(
                            FlagIssuesResult(
                              markedNoIssues: false,
                              issues: [_selected!],
                              notes: _notes.text,
                            ),
                          ),
                          child: Text('Flag 1 issue',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InspectionColors.shutterBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () => Navigator.of(context).pop(
                            FlagIssuesResult(
                              markedNoIssues: true,
                              issues: const [],
                              notes: _notes.text,
                            ),
                          ),
                          child: Text('Mark as no issues',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                ),
              ),
              SizedBox(height: 16.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(DropdownOption o) {
    final value = o.value ?? o.label ?? '';
    final selected = _selected == value;
    final color = _issueColor(o);
    return GestureDetector(
      onTap: () =>
          setState(() => _selected = selected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(46) : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            width: 1.5,
            color: selected ? color : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, color: color, size: 13.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              o.label ?? value,
              style: TextStyle(
                fontSize: 13.sp,
                color: selected ? color : Colors.white70,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
