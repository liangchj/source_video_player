import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

// 全局 GetIt 实例
final GetIt locator = GetIt.instance;

// 初始化服务注册
void setupLocator() {
  // 懒加载注册 AppRouter 单例
  locator.registerLazySingleton<AppRouter>(() => AppRouter());
}

GoRouter get appGoRouter => locator<AppRouter>().router;