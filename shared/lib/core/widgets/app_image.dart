// lib/core/widgets/app_image.dart
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AppImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      package: 'shared_le_transporteur',
      width: width,
      height: height,
      fit: fit,
      // Optional: Add a fade-in effect for network images in the future
    );
  }
}
