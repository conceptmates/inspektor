import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/inspection_submission_builder.dart';
import '../../../models/inspection_template_model.dart';
import '../../../models/local_inspection.dart';

/// White end-drawer listing inspection sections with per-section completion
/// ticks and an expandable per-field sublist. Matches formUi.md "Sections
/// drawer". Pure presentation — selection is surfaced via callbacks.
class InspectionSectionsDrawer extends StatefulWidget {
  const InspectionSectionsDrawer({
    super.key,
    required this.sections,
    required this.draft,
    required this.activeSection,
    required this.onSelectSection,
    required this.onSelectField,
  });

  final List<InspectionSection> sections;
  final LocalInspection draft;
  final int activeSection;
  final ValueChanged<int> onSelectSection;
  final void Function(int sectionIndex, int fieldIndex) onSelectField;

  static const Color _accent = Color(0xFF448AFF);
  static const Color _accentFill = Color(0x1A448AFF);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _border = Color(0xFFE4E7EB);
  static const Color _surfaceHigh = Color(0xFFF0F2F5);

  @override
  State<InspectionSectionsDrawer> createState() =>
      _InspectionSectionsDrawerState();
}

class _InspectionSectionsDrawerState extends State<InspectionSectionsDrawer> {
  late int _expanded = widget.activeSection;

  bool _fieldComplete(InspectionField f) {
    final key = fieldKey(f);
    final d = widget.draft;
    final type = f.fieldType;
    if (type == 'image' || f.hasImage || f.hasMultipleImages) {
      return d.itemImages[key] != null ||
          (d.itemMultiImages[key]?.isNotEmpty ?? false);
    }
    if (type == 'video' || f.hasVideo) return d.itemVideos[key] != null;
    if (type == 'audio') return d.itemAudios[key] != null;
    if (type == 'file' || f.hasFile) return d.itemFiles[key] != null;
    final v = d.itemValues[key] ?? d.textFieldValues[key];
    return v != null && v.isNotEmpty && v != 'N/A';
  }

  bool _sectionComplete(InspectionSection s) =>
      s.fields.isNotEmpty && s.fields.every(_fieldComplete);

  IconData _sectionIcon(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.contains('document')) return Icons.description;
    if (n.contains('body') || n.contains('panel')) return Icons.directions_car;
    if (n.contains('tire') || n.contains('tyre')) return Icons.tire_repair;
    if (n.contains('a_c') || n.contains('ac') || n.contains('air')) {
      return Icons.ac_unit;
    }
    if (n.contains('test') || n.contains('drive')) return Icons.drive_eta;
    if (n.contains('summary') || n.contains('remark')) return Icons.summarize;
    return Icons.checklist;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
              child: Row(
                children: [
                  Icon(Icons.layers_outlined,
                      color: InspectionSectionsDrawer._accent, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text('Sections',
                      style: TextStyle(
                        color: InspectionSectionsDrawer._textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                      )),
                  const Spacer(),
                  Text('${widget.sections.length} total',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12.sp)),
                ],
              ),
            ),
            const Divider(
                color: InspectionSectionsDrawer._border, height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.w),
                itemCount: widget.sections.length,
                itemBuilder: (context, index) =>
                    _section(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, int index) {
    final s = widget.sections[index];
    final isActive = index == widget.activeSection;
    final isCompleted = _sectionComplete(s);
    final isExpanded = _expanded == index;

    final Color tickFill = isCompleted
        ? Colors.green.withAlpha(31)
        : isActive
            ? InspectionSectionsDrawer._accent.withAlpha(31)
            : InspectionSectionsDrawer._surfaceHigh;
    final IconData tickIcon =
        isCompleted ? Icons.check_circle_outline : _sectionIcon(s.name);
    final Color tickColor = isCompleted
        ? Colors.green
        : isActive
            ? InspectionSectionsDrawer._accent
            : (Colors.grey[500] ?? Colors.grey);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.fromLTRB(12.w, 2.w, 4.w, 2.w),
          selected: isActive,
          selectedTileColor: InspectionSectionsDrawer._accentFill,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          onTap: () => widget.onSelectSection(index),
          leading: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: tickFill,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(tickIcon, size: 18.sp, color: tickColor),
          ),
          title: Text(
            s.title ?? s.name ?? 'Section ${index + 1}',
            style: TextStyle(
              color: isActive
                  ? InspectionSectionsDrawer._accent
                  : InspectionSectionsDrawer._textPrimary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          subtitle: Text(
            '${s.fields.length} field(s)',
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          ),
          trailing: IconButton(
            splashRadius: 18.r,
            constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
            onPressed: () =>
                setState(() => _expanded = isExpanded ? -1 : index),
            icon: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more_rounded,
                  color: isActive
                      ? InspectionSectionsDrawer._accent
                      : Colors.grey[500],
                  size: 20.sp),
            ),
          ),
        ),
        // ponytail: AnimatedSize + conditional child so COLLAPSED sections
        // don't build their full field Column. AnimatedCrossFade built both
        // children every frame → hundreds of field widgets per scroll = jank.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: isExpanded
              ? _fieldList(index, isCompleted, isActive)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _fieldList(int sectionIndex, bool isCompleted, bool isActive) {
    // Sort by `order` exactly like the screen's _fields(), so the index emitted
    // by onSelectField lines up with the field the screen renders at _itemIndex.
    final fields = [...widget.sections[sectionIndex].fields]
      ..sort((a, b) => a.order.compareTo(b.order));
    final Color borderColor = isCompleted
        ? Colors.green.withAlpha(102)
        : isActive
            ? InspectionSectionsDrawer._accent.withAlpha(102)
            : InspectionSectionsDrawer._border;
    return Container(
      margin: EdgeInsets.only(left: 48.w, right: 8.w, bottom: 4.w),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 2.w, color: borderColor)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < fields.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () => widget.onSelectField(sectionIndex, i),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: InspectionSectionsDrawer._surfaceHigh,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text('${i + 1}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        fields[i].title ?? fieldKey(fields[i]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: InspectionSectionsDrawer._textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
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
