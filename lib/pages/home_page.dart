import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:source_video_player/view_model/home_view_model.dart';

import '../state/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late HomeViewModel viewModel;
  HomeState get homeState => viewModel.state;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    homeState.tabController.value = TabController(
      initialIndex: homeState.currentIndex.value,
      length: homeState.tabPageList.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Watch(
          (context) => TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: homeState.tabController.value,
            children: homeState.tabPageList,
          ),
        ),
      ),
      bottomNavigationBar: Watch(
        (context) => BottomNavigationBar(
          currentIndex: homeState.currentIndex.value,
          type: BottomNavigationBarType.fixed,
          items: homeState.bottomTabList,
          onTap: (pageIndex) {
            homeState.currentIndex.value = pageIndex;
            homeState.tabController.value?.index = pageIndex;
          },
        ),
      ),
    );
  }
}
