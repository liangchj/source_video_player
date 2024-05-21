import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/pages/home_page.dart';
import 'package:source_video_player/route/app_pages.dart';
import 'package:source_video_player/route/app_routes.dart';

void main() {
  runApp(GetMaterialApp(
    initialRoute: AppRoutes.index,
    getPages: AppPages.pages,
    home: const SourceVideoPlayerApp(),
  ));
}

class SourceVideoPlayerApp extends StatelessWidget {
  const SourceVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'source video player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

