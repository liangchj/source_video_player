import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';

import '../player/media_kit_player.dart';

class PersonalHomePage extends StatefulWidget {
  const PersonalHomePage({super.key});

  @override
  State<PersonalHomePage> createState() => _PersonalHomePageState();
}

class _PersonalHomePageState extends State<PersonalHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text('PersonalHomePage')),
          TextButton(
            onPressed: () {
              List<ChapterModel> chapterList = [
                ChapterModel(
                  name: '1',
                  index: 0,
                  playUrl: "asset://assets/video/test.mp4",
                ),
              ];
              PlayerUtils.openLocalVideo(
                context: context,
                chapterList: chapterList,
                player: MediaKitPlayer(),
              );
            },
            child: Text("测试播放视频"),
          ),
        ],
      ),
    );
  }
}
