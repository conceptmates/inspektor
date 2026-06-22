import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_data_model.freezed.dart';
part 'pagination_data_model.g.dart';

@freezed
abstract class PaginationData with _$PaginationData {
  const PaginationData._();

  const factory PaginationData({
    @JsonKey(name: 'current_page') @Default(1) int currentPage,
    @JsonKey(name: 'last_page') @Default(1) int lastPage,
    @JsonKey(name: 'per_page') @Default(10) int perPage,
    @Default(0) int total,
  }) = _PaginationData;

  factory PaginationData.fromJson(Map<String, dynamic> json) =>
      _$PaginationDataFromJson(json);

  bool get hasMore => currentPage < lastPage;
}
