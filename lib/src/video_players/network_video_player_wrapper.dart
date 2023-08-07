import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_players_demo/src/video_players/network_video_player_widget.dart';

class NetworkVideoPlayerWrapper extends StatefulWidget {
  final String url;
  final Future<String?> Function()? refreshVideo;
  final bool absorbPointers;
  final bool fullScreen;
  final Function()? onTap;
  final Alignment audioButtonAlignment;
  final EdgeInsets? audioButtonPadding;

  const NetworkVideoPlayerWrapper({
    super.key,
    required this.url,
    this.refreshVideo,
    this.absorbPointers = true,
    this.fullScreen = false,
    this.onTap,
    this.audioButtonPadding,
    this.audioButtonAlignment = Alignment.topLeft,
  });

  @override
  State<NetworkVideoPlayerWrapper> createState() => _NetworkVideoPlayerWrapperState();
}

class _NetworkVideoPlayerWrapperState extends State<NetworkVideoPlayerWrapper>
    with SingleTickerProviderStateMixin {
  late String url = widget.url;
  double playIconOpacity = 0;
  double pauseIconOpacity = 0;

  int refreshTries = 0;
  String? loadingError;

  static const Duration iconFlashDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    print('Initializing video player wrapper');
  }

  _flashPlayIcon() {
    setState(() {
      pauseIconOpacity = 0;
      playIconOpacity = 1;
      Future.delayed(Duration(milliseconds: (iconFlashDuration.inMilliseconds * 1.5).round()), () {
        setState(() {
          playIconOpacity = 0;
        });
      });
    });
  }

  _flashPauseIcon() {
    setState(() {
      playIconOpacity = 0;
      pauseIconOpacity = 1;
      Future.delayed(Duration(milliseconds: (iconFlashDuration.inMilliseconds * 1.5).round()), () {
        setState(() {
          pauseIconOpacity = 0;
        });
      });
    });
  }

  @override
  void dispose() {
    print('Disposing video player wrapper');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (loadingError != null && widget.refreshVideo != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Icon(
              Icons.error,
              color: colorScheme.primaryContainer,
              size: 25,
            )),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        NetworkVideoPlayerWidget(
          key: ValueKey(url),
          url: url,
          absorbPointers: widget.absorbPointers,
          fullScreen: widget.fullScreen,
          audioButtonAlignment: widget.audioButtonAlignment,
          audioButtonPadding: widget.audioButtonPadding,
          onTap: (playing) {
            widget.onTap?.call();
            if (playing) {
              _flashPlayIcon();
            } else {
              _flashPauseIcon();
            }
          },
        ),
        Center(
          child: AnimatedOpacity(
            opacity: pauseIconOpacity,
            duration: iconFlashDuration,
            curve: Curves.fastEaseInToSlowEaseOut,
            child: SizedBox(
              width: 70,
              height: 70,
              child: Material(
                shape: const CircleBorder(),
                color: colorScheme.background.withOpacity(0.3),
                child: Icon(
                  Icons.pause,
                  color: colorScheme.primary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AnimatedOpacity(
            opacity: playIconOpacity,
            duration: iconFlashDuration,
            curve: Curves.fastEaseInToSlowEaseOut,
            child: SizedBox(
              width: 70,
              height: 70,
              child: Material(
                shape: const CircleBorder(),
                color: colorScheme.background.withOpacity(0.3),
                child: Icon(
                  Icons.play_arrow,
                  color: colorScheme.primary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
