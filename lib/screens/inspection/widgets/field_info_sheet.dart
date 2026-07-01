import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/inspection_template_model.dart';
import 'cached_reference_image.dart';

/// "What to inspect" help sheet: field title, description (from metadata), and
/// reference media (from the API — no hardcoded explanations).
class FieldInfoSheet {
  static void show(BuildContext context, InspectionField field) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FieldInfoBody(field: field),
    );
  }
}

class _FieldInfoBody extends StatelessWidget {
  const _FieldInfoBody({required this.field});
  final InspectionField field;

  String? get _description {
    final m = field.metadata;
    if (m == null) return null;
    final d = m['description'] ?? m['help'] ?? m['hint'];
    return d?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.title ?? 'Field',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (_description != null) ...[
              SizedBox(height: 12.w),
              Text(_description!, style: theme.textTheme.bodyMedium),
            ],
            if (field.referenceMedia.isNotEmpty) ...[
              SizedBox(height: 20.w),
              Text('Reference', style: theme.textTheme.titleSmall),
              SizedBox(height: 12.w),
              SizedBox(
                height: 140.w,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: field.referenceMedia.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (_, i) => _RefMedia(field.referenceMedia[i]),
                ),
              ),
            ],
            SizedBox(height: 20.w),
          ],
        ),
      ),
    );
  }
}

class _RefMedia extends StatelessWidget {
  const _RefMedia(this.media);
  final ReferenceMedia media;

  @override
  Widget build(BuildContext context) {
    final url = media.url ?? media.filePath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: url == null
              ? const SizedBox.shrink()
              : CachedReferenceImage(url,
                  height: 110.w,
                  width: 140.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.broken_image, size: 40.sp)),
        ),
        if (media.description != null)
          SizedBox(
            width: 140.w,
            child: Text(media.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}
