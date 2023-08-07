import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video_players_demo/src/default_properties.dart';
import 'package:video_players_demo/src/loader.dart';
import 'package:video_players_demo/src/mux_helper.dart';
import 'package:video_players_demo/src/video_players/network_video_player_view_model.dart';
import 'package:video_players_demo/src/video_players/video_player_controllers_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NetworkVideoPlayerWidget extends ConsumerWidget {
  final String url;
  final bool absorbPointers;
  final bool fullScreen;
  final Function(bool)? onTap;
  final Alignment audioButtonAlignment;
  final EdgeInsets? audioButtonPadding;

  const NetworkVideoPlayerWidget({
    super.key,
    required this.url,
    this.absorbPointers = true,
    this.fullScreen = false,
    this.onTap,
    this.audioButtonPadding,
    this.audioButtonAlignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context, ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final controllerViewModel = ref.watch(networkVideoPlayerProvider(url));
    final loading = controllerViewModel.loading;

    if (loading || controllerViewModel.controller == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(MuxHelper.thumbnailFromVideo(url)),
          Container(
            color: colorScheme.background.withOpacity(0.2),
            child: const Center(child: Loader()),
          )
        ],
      );
    }

    final controller = controllerViewModel.controller!;
    final playingVideo = ref.watch(playingVideoProvider);
    final isPlaying = controller.value.isPlaying == true;
    if (playingVideo == url && !isPlaying) {
      controller.play();
    } else if (playingVideo != url) {
      controller.pause();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!loading) ...[
          AbsorbPointer(
            absorbing: absorbPointers,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (controller.value.isPlaying) {
                  onTap?.call(false);
                  ref.read(playingVideoProvider.notifier).state = null;
                } else {
                  onTap?.call(true);
                  ref.read(playingVideoProvider.notifier).state = url;
                }
              },
              child: VisibilityDetector(
                key: Key(url),
                onVisibilityChanged: (visibilityInfo) {
                  final visiblePercentage = visibilityInfo.visibleFraction * 100;
                  final shouldPlay = visiblePercentage >= 70;
                  if (shouldPlay && playingVideo != url) {
                    ref.read(playingVideoProvider.notifier).state = url;
                  }
                },
                child: Center(
                  child: fullScreen
                      ? AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        )
                      : SizedBox.expand(
                          child: FittedBox(
                            fit: (controller.value.aspectRatio < 1 ||
                                    audioButtonAlignment != Alignment.topLeft)
                                ? BoxFit.cover
                                : BoxFit.fitWidth,
                            child: SizedBox(
                              width: controller.value.size.width,
                              height: controller.value.size.height,
                              child: VideoPlayer(key: ValueKey(url), controller),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          Align(
            alignment: audioButtonAlignment,
            child: Consumer(builder: (context, ref, _) {
              final bool playingAudio = ref.watch(videosPlayingAudioProvider);
              final currentVolume = controller.value.volume;
              if (playingAudio && currentVolume == 0) {
                controller.setVolume(1);
              } else if (!playingAudio && currentVolume == 1) {
                controller.setVolume(0);
              }
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  ref.read(videosPlayingAudioProvider.notifier).state = !playingAudio;
                },
                child: SafeArea(
                  top: fullScreen,
                  bottom: fullScreen,
                  child: Container(
                    margin: defaultPaddingAll
                        .add(
                          EdgeInsets.only(top: fullScreen ? 48 : 0),
                        )
                        .add(audioButtonPadding ?? EdgeInsets.zero),
                    width: 30,
                    height: 30,
                    child: Material(
                      shape: const CircleBorder(),
                      color: colorScheme.background.withOpacity(0.4),
                      child: Icon(
                        playingAudio ? Icons.volume_up : Icons.volume_off,
                        color: Colors.black54,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            }),
          )
        ] else ...[
          Image.network(MuxHelper.thumbnailFromVideo(url)),
          Container(
            color: colorScheme.background.withOpacity(0.2),
            child: const Center(child: Loader()),
          )
        ],
      ],
    );
  }
}
