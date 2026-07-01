import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    @JsonKey(fromJson: _rolesFromJson) @Default(<String>[]) List<String> roles,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isAdmin => roles.contains('admin');
  bool hasRole(String role) => roles.contains(role);
}

/// API sends roles as `[{name: 'inspector'}, ...]` (or sometimes `['inspector']`).
List<String> _rolesFromJson(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => e is Map ? (e['name']?.toString() ?? '') : e.toString())
      .where((s) => s.isNotEmpty)
      .toList();
}
