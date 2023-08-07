import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double size;
  const Loader({
    super.key,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.horizontalRotatingDots(
      color: color ?? Theme.of(context).colorScheme.primary,
      size: size,
    );
  }
}
