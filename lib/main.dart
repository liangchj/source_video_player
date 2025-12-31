import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'permission/permission_controller.dart';
import 'permission/permission_service.dart';
import 'route/app_router.dart';
import 'route/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // CommonCache();

  // 1. 初始化 GetIt
  setupLocator();
  // 2. 初始化 GoRouter
  locator<AppRouter>().initRouter();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // 初始化权限服务
    final permissionService = PermissionService();

    // 检查是否是首次启动
    bool isFirstLaunch = true; //await _checkFirstLaunch();
    if (isFirstLaunch) {
      // 首次启动时请求媒体权限（非强制）
      await permissionService.requestMediaPermissionOnFirstLaunch();
      // 标记为非首次启动
      // await _markFirstLaunchCompleted();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 从 GetIt 中获取 GoRouter 实例
      routerConfig: locator<AppRouter>().router,
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
