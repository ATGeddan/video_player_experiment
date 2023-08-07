// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_players_demo/src/app_image.dart';
// import 'package:video_players_demo/src/loader.dart';
// import 'package:video_players_demo/src/mux_helper.dart';
//
// class NetworkVideoPlayerWidget2 extends StatefulWidget {
//   final String url;
//
//   const NetworkVideoPlayerWidget2({
//     super.key,
//     required this.url,
//   });
//
//   @override
//   State<NetworkVideoPlayerWidget2> createState() => _NetworkVideoPlayerWidgetState();
// }
//
// class _NetworkVideoPlayerWidgetState extends State<NetworkVideoPlayerWidget2> {
//   VideoPlayerController? controller;
//   bool loading = true;
//   Timer? _initTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeController();
//   }
//
//   _initializeController() async {
//     _initTimer = Timer(const Duration(milliseconds: 500), () async {
//       if (!mounted) {
//         return;
//       }
//       controller = VideoPlayerController.networkUrl(
//         Uri.parse(widget.url),
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: true,
//         ),
//       );
//       await controller?.initialize();
//       await controller?.setLooping(true);
//       setState(() {
//         loading = false;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _initTimer?.cancel();
//     controller = null;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     final ColorScheme colorScheme = theme.colorScheme;
//
//     if (loading || controller == null) {
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           AppImage(MuxHelper.thumbnailFromVideo(widget.url)),
//           Container(
//             color: colorScheme.background.withOpacity(0.2),
//             child: const Center(child: Loader()),
//           )
//         ],
//       );
//     }
//
//     // final playingVideo = ref.watch(playingVideoProvider);
//     // final isPlaying = controller!.value.isPlaying == true;
//     // if (playingVideo == widget.url && !isPlaying) {
//     //   controller!.play();
//     // } else if (playingVideo != widget.url) {
//     //   controller!.pause();
//     // }
//
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         if (!loading) ...[
//           GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: () {
//               if (controller!.value.isPlaying) {
//                 // onTap?.call(false);
//                 // ref.read(playingVideoProvider.notifier).state = null;
//               } else {
//                 // onTap?.call(true);
//                 // ref.read(playingVideoProvider.notifier).state = widget.url;
//               }
//             },
//             child: Center(
//               child: SizedBox.expand(
//                 child: FittedBox(
//                   fit: BoxFit.fitWidth,
//                   child: SizedBox(
//                     width: controller!.value.size.width,
//                     height: controller!.value.size.height,
//                     child: VideoPlayer(controller!),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ] else ...[
//           AppImage(MuxHelper.thumbnailFromVideo(widget.url)),
//           Container(
//             color: colorScheme.background.withOpacity(0.2),
//             child: const Center(child: Loader()),
//           )
//         ],
//       ],
//     );
//   }
// }
