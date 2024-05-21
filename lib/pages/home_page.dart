import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/common/app_constants.dart';
import 'package:source_video_player/getx_controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(controller.appTitle.value),
          ),
          body: controller.requestPermission.value
              ? PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.tabController,
                  children: controller.tabPageList,
                )
              : const Center(
                  child: Text(
                    "请先获取权限",
                    style: TextStyle(
                        fontSize: AppConstants.textSize, color: Colors.black),
                  ),
                ),
          bottomNavigationBar: controller.requestPermission.value
              ? BottomNavigationBar(
                  currentIndex: controller.currentTabIndex.value,
                  type: BottomNavigationBarType.fixed,
                  items: controller.bottomTabList,
                  selectedFontSize: AppConstants.textSize,
                  onTap: (pageIndex) => controller.currentTabIndex(pageIndex),
                )
              : null,
        ));
  }
}
