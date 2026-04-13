import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// A premium, high-performance image widget that implements intelligent caching
/// and professional shimmer loading effects.
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showShimmer;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // SMOOTH FADE TRANSITION
      fadeInDuration: const Duration(milliseconds: 500),
      fadeOutDuration: const Duration(milliseconds: 300),
      // PREMIUM SHIMMER PLACEHOLDER
      placeholder: (context, url) => showShimmer
          ? _buildShimmer(context, isDark)
          : _buildStaticPlaceholder(context, isDark),
      // ELEGANT ERROR STATE
      errorWidget: (context, url, error) => _buildErrorWidget(context, isDark),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildShimmer(BuildContext context, bool isDark) {
    final Color baseColor = isDark
        ? Colors.white.withAlpha(13)
        : Colors.grey[300]!;
    final Color highlightColor = isDark
        ? Colors.white.withAlpha(26)
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildStaticPlaceholder(BuildContext context, bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.white.withAlpha(13) : Colors.grey[200],
    );
  }

  Widget _buildErrorWidget(BuildContext context, bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? Colors.white.withAlpha(26) : Colors.grey[300],
      child: Icon(
        Icons.broken_image_rounded,
        color: isDark ? Colors.white24 : Colors.grey[400],
      ),
    );
  }
}
