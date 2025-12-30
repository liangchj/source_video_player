import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'permission/permission_controller.dart';
import 'route/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // CommonCache();

  /*// 初始化权限服务
  final permissionService = PermissionService();

  // 检查是否是首次启动
  bool isFirstLaunch = await _checkFirstLaunch();
  if (isFirstLaunch) {
    // 首次启动时请求媒体权限（非强制）
    await permissionService.requestMediaPermissionOnFirstLaunch();
    // 标记为非首次启动
    await _markFirstLaunchCompleted();
  }*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.routes,
      scrollBehavior: const TouchBehaviour(),
      builder: FlutterSmartDialog.init(),
    );
  }
}

class TouchBehaviour extends ScrollBehavior {
  const TouchBehaviour();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
