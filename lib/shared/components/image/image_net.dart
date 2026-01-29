import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageNet extends StatefulWidget {
  const ImageNet({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.boxFit = BoxFit.cover,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit boxFit;

  @override
  State<ImageNet> createState() => _ImageNetState();
}

class _ImageNetState extends State<ImageNet> {
  bool get _isValidUrl {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          uri.hasAuthority &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check for empty or invalid URL safely
    if (!_isValidUrl) {
      // Only print debug message for non-empty invalid URLs
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        debugPrint('⚠️ Invalid image URL: "${widget.imageUrl}"');
      }
      return _buildPlaceholder();
    }

    return Image.network(
      widget.imageUrl!,
      height: widget.height,
      width: widget.width,
      fit: widget.boxFit,
      // ✅ Shimmer while loading
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      // ✅ Safe fallback in case of load error
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        debugPrint(
            '⚠️ Image load error: $error for URL: "${widget.imageUrl}"');
        return _buildPlaceholder();
      },
    );
  }
}
