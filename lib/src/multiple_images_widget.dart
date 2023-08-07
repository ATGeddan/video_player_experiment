import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_players_demo/src/default_properties.dart';
import 'package:video_players_demo/src/full_screen_images/full_screen_images_screen.dart';
import 'package:video_players_demo/src/video_players/network_video_player_wrapper.dart';
import 'package:video_players_demo/src/video_players/video_thumbnail_widget.dart';

import 'video_players/video_player_controllers_provider.dart';

class MultipleImagesWidget extends ConsumerStatefulWidget {
  final List<String> videos;
  static const int scaleDownWidth = 800;

  const MultipleImagesWidget({super.key, required this.videos});

  @override
  ConsumerState<MultipleImagesWidget> createState() => _MultipleImagesWidgetState();
}

class _MultipleImagesWidgetState extends ConsumerState<MultipleImagesWidget> {
  final ScrollController smallImagesScrollController = ScrollController();
  final PageController controller = PageController();
  late String selectedItem = widget.videos.first;

  late final smallImageSize = MediaQuery.of(context).size.width * 0.12;
  static const double smallImageSpacing = 10;

  @override
  void dispose() {
    controller.dispose();
    smallImagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final videosList = widget.videos;
    final int totalCount = videosList.length;

    return GestureDetector(
      onTap: () async {
        final currentIndex = videosList.indexOf(selectedItem);
        ref.read(videosPlayingAudioProvider.notifier).state = true;
        final index = await Navigator.push(context, MaterialPageRoute(builder: (_) {
          return FullScreenImages(
            videos: videosList,
            initialIndex: currentIndex,
          );
        }));
        if (index != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.jumpToPage(index as int);
          });
        }
      },
      child: AspectRatio(
        aspectRatio: 0.75,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              PageView(
                controller: controller,
                onPageChanged: (index) {
                  if (!mounted) {
                    return;
                  }
                  HapticFeedback.mediumImpact();
                  final playingVideo = ref.read(playingVideoProvider);
                  if (playingVideo != null) {
                    ref.read(playingVideoProvider.notifier).state = null;
                  }
                  setState(() {
                    selectedItem = videosList[index];
                  });
                  const visibleImagesCount = 4;
                  if (totalCount > visibleImagesCount &&
                      totalCount - index > (visibleImagesCount - 1)) {
                    smallImagesScrollController.animateTo(
                      index == 0
                          ? 0
                          : (index * (smallImageSize + smallImageSpacing)) +
                              (smallImageSpacing / 2),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                    );
                  }
                },
                children: [
                  ...videosList.map(
                    (e) {
                      return ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: defaultBorderRadius,
                        child: NetworkVideoPlayerWrapper(
                          key: ValueKey(e),
                          url: e,
                          fullScreen: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (totalCount > 1) ...[
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: SizedBox(
                    child: SingleChildScrollView(
                      controller: smallImagesScrollController,
                      padding: const EdgeInsets.only(left: smallImageSpacing, bottom: 16, top: 8),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...videosList.map((video) {
                            final index = videosList.indexOf(video);
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
                                margin: const EdgeInsetsDirectional.only(end: smallImageSpacing),
                                width: 45,
                                height: 45,
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
                )
              ],
            ],
          );
        }),
      ),
    );
  }
}
