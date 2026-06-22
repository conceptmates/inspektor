import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_inspection.freezed.dart';
part 'local_inspection.g.dart';

/// Unified offline record (replaces old InspectionStorageModel + LocalInspection).
/// One model serves the in-progress draft, the pending submission queue, and the
/// submitted record — distinguished by [status]. Stored as JSON in a Hive
/// `Box<String>` (no TypeAdapter codegen needed).
enum LocalStatus { draft, pending, submitted }

@freezed
abstract class LocalInspection with _$LocalInspection {
  const LocalInspection._();

  const factory LocalInspection({
    required String id,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(LocalStatus.draft) LocalStatus status,
    @Default(false) bool isCompleted,
    int? inspectionId,
    @Default(0) int currentSection,
    Map<String, dynamic>? vehicleDetails,
    Map<String, dynamic>? inspectionTemplate,

    // Working per-item draft state (keyed by field uniqueId).
    @Default(<String, String>{}) Map<String, String> itemValues,
    @Default(<String, String>{}) Map<String, String> itemRemarks,
    @Default(<String, String>{}) Map<String, String> textFieldValues,
    @Default(<String, String>{}) Map<String, String> itemImages,
    @Default(<String, String>{}) Map<String, String> itemVideos,
    @Default(<String, String>{}) Map<String, String> itemAudios,
    @Default(<String, String>{}) Map<String, String> itemFiles,
    @Default(<String, List<String>>{})
    Map<String, List<String>> itemMultiImages,
    @Default(<String, List<String>>{})
    Map<String, List<String>> itemFlaggedIssues,

    // Submission.
    Map<String, dynamic>? submissionData,
    @Default(<PendingMedia>[]) List<PendingMedia> pendingMedia,
  }) = _LocalInspection;

  factory LocalInspection.fromJson(Map<String, dynamic> json) =>
      _$LocalInspectionFromJson(json);

  bool get hasPendingMedia => pendingMedia.isNotEmpty;
}

/// A media file still on a local path, queued for upload during sync.
@freezed
abstract class PendingMedia with _$PendingMedia {
  const factory PendingMedia({
    required String localPath,
    required String section,
    required String itemId,
    @Default('image') String kind, // image | video | audio | file
  }) = _PendingMedia;

  factory PendingMedia.fromJson(Map<String, dynamic> json) =>
      _$PendingMediaFromJson(json);
}
