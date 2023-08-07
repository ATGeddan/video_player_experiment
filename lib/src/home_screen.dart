import 'package:flutter/material.dart';
import 'package:video_players_demo/src/home_cell.dart';
import 'package:video_players_demo/src/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          return HomeCell(videos: mockVideos[index]);
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: mockVideos.length,
      ),
    );
  }
}
