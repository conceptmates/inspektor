import 'dart:io';

import 'package:flutter/material.dart';

import '../../../services/reference_media_cache.dart';
import '../../../utils/media_url.dart';

/// Reference (guide) image that prefers the on-disk cache so guides stay
/// visible offline, falling back to the network on a cache miss. Drop-in for
/// `Image.network` wherever admin reference media is shown (field info sheet,
/// camera HUD, fullscreen).
class CachedReferenceImage extends StatelessWidget {
  const CachedReferenceImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      // ponytail: re-runs the disk check on rebuild; existsSync is cheap (no
      // network), so caching the future isn't worth the StatefulWidget.
      future: ReferenceMediaCache.cachedFile(url),
      builder: (context, snap) {
        // Hold a blank box until the (near-instant) disk check resolves so a
        // cached file never triggers a spurious network fetch first.
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        final file = snap.data;
        if (file != null) {
          return Image.file(file,
              width: width,
              height: height,
              fit: fit,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              errorBuilder: errorBuilder);
        }
        return Image.network(mediaUri(url).toString(),
            width: width,
            height: height,
            fit: fit,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            errorBuilder: errorBuilder);
      },
    );
  }
}
