import 'package:flutter_riverpod/flutter_riverpod.dart';

final videosPlayingAudioProvider = StateProvider<bool>((ref) => false);
final playingVideoProvider = StateProvider<String?>((ref) => null);
// final playingVideoControllerProvider = StateProvider<VideoPlayerController?>((ref) => null);
