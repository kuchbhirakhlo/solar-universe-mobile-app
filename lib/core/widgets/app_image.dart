import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image from a Firestore-managed URL. The admin panel stores some images as
/// `data:image/...;base64,...` strings (not HTTP URLs), which
/// [CachedNetworkImage] can't load — those are decoded once and shown from
/// memory; real http(s) URLs go through the normal cached network path.
class AppImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget Function()? fallback;

  const AppImage({super.key, required this.url, this.fit = BoxFit.cover, this.fallback});

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(AppImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _decode();
  }

  void _decode() {
    _bytes = null;
    if (!widget.url.startsWith('data:')) return;
    try {
      _bytes = UriData.parse(widget.url).contentAsBytes();
    } catch (_) {
      final comma = widget.url.indexOf(',');
      if (comma != -1) {
        try {
          _bytes = base64Decode(widget.url.substring(comma + 1).replaceAll(RegExp(r'\s'), ''));
        } catch (_) {}
      }
    }
  }

  Widget _fallback() => widget.fallback?.call() ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) return _fallback();
    if (widget.url.startsWith('data:')) {
      final bytes = _bytes;
      if (bytes == null) return _fallback();
      return Image.memory(
        bytes,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: widget.fit,
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }
}
