
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:source_video_player/state/signals_base_state.dart';

import '../pages/media_library_home_page.dart';
import '../pages/net_resource_home_page.dart';
import '../pages/personal_home_page.dart';

class HomeState extends SignalsBaseState {
  final Signal<TabController?> tabController = Signal(null);
  late List<Widget> tabPageList;
  final Signal<int> currentIndex = Signal<int>(1);
  final List<BottomNavigationBarItem> bottomTabList = [
    const BottomNavigationBarItem(label: "网络视频", icon: Icon(Icons.home)),
    const BottomNavigationBarItem(
      label: "媒体库",
      icon: Icon(Icons.video_collection_rounded),
    ),
    const BottomNavigationBarItem(
      label: "我的",
      icon: Icon(Icons.people_alt_rounded),
    ),
  ];

  @override
  void init() {
    tabPageList = [
      const NetResourceHomePage(),
      const MediaLibraryHomePage(),
      const PersonalHomePage(),
    ];
  }

  @override
  void dispose() {
    currentIndex.dispose();
    tabController.dispose();
  }


}