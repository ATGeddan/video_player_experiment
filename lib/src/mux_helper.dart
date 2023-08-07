class MuxHelper {
  static String thumbnailFromVideo(String videoUrl) {
    return videoUrl.replaceAll('stream.mux', 'image.mux').replaceAll('.m3u8', '/thumbnail.png');
  }
}
