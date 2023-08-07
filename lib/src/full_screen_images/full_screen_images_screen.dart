import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_players_demo/src/default_properties.dart';
import 'package:video_players_demo/src/full_screen_images/full_screen_images_carousel.dart';
import 'package:video_players_demo/src/full_screen_images/zoomable_media.dart';
import 'package:video_players_demo/src/video_players/video_player_controllers_provider.dart';
import 'package:video_players_demo/src/video_players/video_thumbnail_widget.dart';

class FullScreenImages extends ConsumerStatefulWidget {
  final List<String> videos;
  final int initialIndex;

  const FullScreenImages({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  ConsumerState<FullScreenImages> createState() => _FullScreenImagesState();
}

class _FullScreenImagesState extends ConsumerState<FullScreenImages> {
  late PageController controller;
  late String selectedItem = [
    ...widget.videos,
  ].elementAt(widget.initialIndex);
  double _scale = 1;
  double _opacity = 0;
  double _top = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  _updateScale(double scale) {
    const minScale = ZoomableMedia.minScale;
    if (scale > minScale && _opacity == 1) {
      setState(() {
        _opacity = 0;
      });
    } else if (scale == ZoomableMedia.minScale && _opacity == 0) {
      setState(() {
        _opacity = 1;
      });
    }

    if (scale == minScale && _scale == minScale) {
      return;
    }
    if (scale > minScale && _scale > minScale) {
      return;
    }
    setState(() {
      _scale = scale;
    });
  }

  _pop(BuildContext context) {
    Navigator.pop(context, widget.videos.indexOf(selectedItem));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final videos = widget.videos;
    final totalCount = videos.length;
    const duration = Duration(milliseconds: 150);
    final bool isDismissible = _scale == ZoomableMedia.minScale;
    const double smallImageSpacing = 8;
    const double imageSizeToUse = 45;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              top: _top,
              left: 0.0,
              right: 0.0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: isDismissible
                    ? (DragUpdateDetails details) {
                        setState(() {
                          _top += details.delta.dy;
                        });
                      }
                    : null,
                onVerticalDragEnd: isDismissible
                    ? (DragEndDetails details) {
                        final double dragDistance = details.velocity.pixelsPerSecond.dy;
                        const dismissThreshold = 250;
                        if (dragDistance > dismissThreshold || dragDistance < -dismissThreshold) {
                          _pop(context);
                        } else {
                          setState(() {
                            _top = 0.0;
                          });
                        }
                      }
                    : null,
                child: FullScreenImagesCarousel(
                  pageController: controller,
                  videos: videos,
                  onPageChanged: (index) {
                    HapticFeedback.mediumImpact();
                    final playingVideo = ref.read(playingVideoProvider);
                    if (playingVideo != null) {
                      ref.read(playingVideoProvider.notifier).state = null;
                    }
                    setState(() {
                      selectedItem = videos[index];
                    });
                  },
                  onScaleUpdate: (scale) {
                    _updateScale(scale);
                  },
                  onImageTap: () {
                    setState(() {
                      _opacity = 1 - _opacity;
                    });
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: duration,
                curve: Curves.ease,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CloseButton(
                          color: Colors.blueAccent,
                          onPressed: () {
                            _pop(context);
                          },
                        ),
                        Flexible(
                          child: Text(
                            'The Title',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: duration,
                curve: Curves.ease,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (totalCount > 1) ...[
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...videos.map((video) {
                                final index = videos.indexOf(video);
                                final bool isSelected = video == selectedItem;
                                return GestureDetector(
                                  onTap: () {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      selectedItem = video;
                                    });
                                    HapticFeedback.mediumImpact();
                                    controller.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsetsDirectional.only(end: smallImageSpacing),
                                    width: imageSizeToUse,
                                    height: imageSizeToUse,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: defaultBorderRadius,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? colorScheme.secondary.withOpacity(0.6)
                                              : colorScheme.primary.withOpacity(0.4),
                                          blurRadius: 3,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: VideoThumbnailWidget(
                                      url: video.toString(),
                                      playButtonAlignment: Alignment.center,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
