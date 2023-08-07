import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_players_demo/src/video_players/network_video_player_wrapper.dart';

class ZoomableMedia extends StatefulWidget {
  final String url;
  final Function()? onTap;
  final Function(double) onScaleUpdate;
  final bool isVideo;

  const ZoomableMedia({
    super.key,
    required this.url,
    required this.onScaleUpdate,
    this.onTap,
    this.isVideo = false,
  });

  static const double minScale = 1.0;
  static const double maxScale = 3.0;

  @override
  State<ZoomableMedia> createState() => _ZoomableMediaState();
}

class _ZoomableMediaState extends State<ZoomableMedia> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  double _scale = 1;
  final minScale = ZoomableMedia.minScale;
  final maxScale = ZoomableMedia.maxScale;

  void _handleDoubleTap(TapDownDetails details) {
    _scale = _transformationController.value.getMaxScaleOnAxis();
    final double targetScale = _scale == minScale ? maxScale : minScale;

    Offset doubleTapPosition = Offset.zero;
    if (targetScale != minScale) {
      doubleTapPosition = _transformationController.toScene(
        details.localPosition,
      );
    }

    final Offset normalizedPosition = Offset(
      doubleTapPosition.dx / _transformationController.value.getMaxScaleOnAxis(),
      doubleTapPosition.dy / _transformationController.value.getMaxScaleOnAxis(),
    );

    final Animation<double> animation = Tween<double>(begin: _scale, end: targetScale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ),
    );

    final Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset(
        _transformationController.value.getTranslation().x,
        _transformationController.value.getTranslation().y,
      ),
      end: Offset(
        doubleTapPosition.dx - normalizedPosition.dx * targetScale,
        doubleTapPosition.dy - normalizedPosition.dy * targetScale,
      ),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );

    _animationController.addListener(() {
      final double newScale = animation.value;
      final Offset newOffset = offsetAnimation.value;
      _transformationController.value = Matrix4.identity()
        ..translate(newOffset.dx, newOffset.dy)
        ..scale(newScale);
    });

    _scale = targetScale;
    widget.onScaleUpdate(_scale);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: minScale,
      maxScale: maxScale,
      onInteractionStart: (details) {},
      onInteractionUpdate: (details) {
        _scale = min(_scale * details.scale, maxScale);
        _scale = max(_scale, minScale);
        widget.onScaleUpdate(_scale);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTapDown: _handleDoubleTap,
        child: NetworkVideoPlayerWrapper(
          key: ValueKey(widget.url),
          url: widget.url,
          absorbPointers: false,
          fullScreen: true,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
