import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jin_flutter_player/jin_flutter_player.dart';
import 'package:jin_flutter_player/params/option_params.dart';
import 'package:source_video_player/getx_controller/play_controller.dart';

class FullScreenPlayPage extends GetView<PlayController> {
  const FullScreenPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) => controller.closePlayPage(didPop),
        child: Center(
          child: JinPlayerView(
            optionParams: OptionParams(
                autoPlay: false,
                aspectRatio: 16 / 10,
                resourceChapterList: controller.resourceChapterList),
          ),
        ),
      ),
    );
  }
}
