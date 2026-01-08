import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:media_kit/media_kit.dart';
import 'package:source_video_player/storage/istorage.dart';
import 'package:source_video_player/utils/logger_utils.dart';

import 'permission/permission_service.dart';
import 'route/app_router.dart';
import 'route/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized;
  // CommonCache();

  await Future.wait([
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);
  // 添加应用生命周期监听
  WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

  // 1. 初始化 GetIt
  setupLocator();
  // 2. 初始化 GoRouter
  locator<AppRouter>().initRouter();
  // 3. 直接请求权限（无需等待存储初始化）
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // 初始化权限服务
    final permissionService = PermissionService();

    // 检查是否是首次启动
    await permissionService.requestMediaPermissionOnFirstLaunch();
  }
  // 4. 异步初始化存储服务
  _initializeStorageAsync();
  runApp(const MyApp());
}

Future<void> _initializeStorageAsync() async {
  try {
    await locator<IStorage>().init();
  } catch (e) {
    LoggerUtils.logger.e("Storage initialization failed: $e");
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      locator.reset();
    }
  }
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
