/// Helpers for turning a remote media URL string into a [Uri] that the native
/// players (AVURLAsset on iOS, ExoPlayer on Android) and the offline cache will
/// accept.
///
/// Backend-served media preserves the original uploaded filename, so admin
/// reference videos frequently contain spaces or other characters that are
/// illegal in a URI (`My Car Video.mp4`). Flutter's HTTP widgets
/// (`Image.network`) percent-encode the path under the hood, which is why
/// images load fine; the native player hands the raw string straight through
/// and silently rejects it — surfacing as a "video won't play" bug.
///
/// [mediaUri] normalises the string so every code path (player, cache key,
/// download) behaves the same.
Uri mediaUri(String raw) {
  final trimmed = raw.trim();
  // `Uri.encodeFull` escapes characters that are illegal in a URI (spaces,
  // unicode, etc.) while leaving the URI structure (`:/?#&=`) and any existing
  // `%xx` escapes untouched, so it is safe to apply to already-encoded URLs.
  return Uri.parse(Uri.encodeFull(trimmed));
}
