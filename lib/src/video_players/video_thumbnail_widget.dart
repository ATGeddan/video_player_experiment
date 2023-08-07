import 'package:flutter/material.dart';
import 'package:video_players_demo/src/mux_helper.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String url;
  final Alignment playButtonAlignment;

  const VideoThumbnailWidget({
    super.key,
    required this.url,
    this.playButtonAlignment = Alignment.topRight,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(MuxHelper.thumbnailFromVideo(widget.url)),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ])),
            child: Align(
              alignment: widget.playButtonAlignment,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
