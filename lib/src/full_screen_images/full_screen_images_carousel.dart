import 'package:flutter/material.dart';
import 'package:video_players_demo/src/full_screen_images/zoomable_media.dart';

class FullScreenImagesCarousel extends StatefulWidget {
  final PageController pageController;
  final List<String> videos;
  final Function(int)? onPageChanged;
  final Function()? onImageTap;
  final Function(double)? onScaleUpdate;

  const FullScreenImagesCarousel({
    super.key,
    required this.pageController,
    required this.videos,
    this.onPageChanged,
    this.onImageTap,
    this.onScaleUpdate,
  });

  @override
  State<FullScreenImagesCarousel> createState() => _FullScreenImagesCarouselState();
}

class _FullScreenImagesCarouselState extends State<FullScreenImagesCarousel> {
  double _scale = 1.0;

  _updateScale(double scale) {
    widget.onScaleUpdate?.call(scale);
    setState(() {
      _scale = scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.videos.length;
    return PageView.builder(
      physics: _scale == ZoomableMedia.minScale
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      controller: widget.pageController,
      itemCount: count,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        return ZoomableMedia(
          url: widget.videos[index],
          isVideo: true,
          onScaleUpdate: _updateScale,
          onTap: widget.onImageTap,
        );
      },
    );
  }
}
