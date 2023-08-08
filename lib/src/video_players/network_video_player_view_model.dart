import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video_players_demo/src/default_change_notifier.dart';

final networkVideoPlayerProvider =
    ChangeNotifierProvider.autoDispose.family<NetworkVideoPlayerViewModel, String>((ref, url) {
  ref.onDispose(() {
    print('Disposing video player provider');
  });
  return NetworkVideoPlayerViewModel(ref, url);
});

class NetworkVideoPlayerViewModel extends DefaultChangeNotifier {
  final Ref ref;
  final String url;
  VideoPlayerController? controller;
  Timer? _initTimer;

  NetworkVideoPlayerViewModel(this.ref, this.url) {
    loading = true;
    _initializeController();
  }

  _initializeController() async {
    _initTimer = Timer(const Duration(milliseconds: 500), () async {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
      await controller?.initialize();
      await controller?.setLooping(true);
      toggleLoading(on: false);
    });
  }

  @override
  void dispose() {
    if (_initTimer?.isActive == true) {
      _initTimer?.cancel();
    }
    controller?.dispose();
    controller = null;
    super.dispose();
  }
}
