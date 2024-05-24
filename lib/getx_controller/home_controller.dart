import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/common/app_constants.dart';
import 'package:source_video_player/pages/media_library_page.dart';
import 'package:source_video_player/pages/net_resource_page.dart';
import 'package:source_video_player/pages/personal_page.dart';
import 'package:source_video_player/utils/permission_utils.dart';

class HomeController extends GetxController {
  var appTitle = "网络资源".obs;
  // 是否已经申请权限
  var requestPermission = false.obs;

  final List<BottomNavigationBarItem> bottomTabList = [
    const BottomNavigationBarItem(label: "网络视频", icon: Icon(Icons.home)),
    const BottomNavigationBarItem(
        label: "媒体库", icon: Icon(Icons.video_collection_rounded)),
    const BottomNavigationBarItem(
        label: "我的", icon: Icon(Icons.people_alt_rounded)),
  ];
  List<Widget> tabPageList = [];
  var currentTabIndex = 0.obs;
  PageController? tabController;

  @override
  void onInit() {
    /*if (kIsWeb) {
      requestPermission(true);
    } else {
      _handleRequestPermission();
    }*/
    _handleRequestPermission();

    tabPageList = [
      const NetResourcePage(),
      const MediaLibraryPage(),
      const PersonalPage()
    ];
    tabController = PageController(initialPage: currentTabIndex.value);
    ever(currentTabIndex, (index) {
      tabController?.jumpToPage(index);
      appTitle(bottomTabList[index].label);
    });
    // Future.delayed(Duration(seconds: 3)).then((value) => requestPermission(true));
    super.onInit();
  }

  // 申请权限
  void _handleRequestPermission() {
    // 检查权限是否已经赋予
    PermissionUtils.checkPermission(
        permissionList: AppConstants.permissionList,
        onPermissionCallback: (flag) {
          if (flag) {
            requestPermission(true);
          } else {
            requestPermission(false);
            // exit(0);
          }
        });
  }
}
