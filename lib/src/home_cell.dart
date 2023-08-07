import 'package:flutter/material.dart';
import 'package:video_players_demo/src/default_properties.dart';
import 'package:video_players_demo/src/multiple_images_widget.dart';

class HomeCell extends StatefulWidget {
  final List<String> videos;

  const HomeCell({super.key, required this.videos});

  @override
  State<HomeCell> createState() => _HomeCellState();
}

class _HomeCellState extends State<HomeCell> {
  @override
  void initState() {
    print('initialising home cell');
    super.initState();
  }

  @override
  void dispose() {
    print('Disposing home cell');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: Colors.blueAccent,
        ),
      ),
      child: MultipleImagesWidget(
        videos: widget.videos,
      ),
    );
  }
}
