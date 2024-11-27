import 'package:flutter/material.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  NetworkImageWithLoader({
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        color: Colors.transparent, // Placeholder color for the loader
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child; // Return the image once loading is complete
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ), // Show loader while the image is being fetched
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error, color: Colors.red); // Error handling
          },
        ),
      ),
    );
  }
}
