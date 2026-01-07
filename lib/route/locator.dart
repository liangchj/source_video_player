import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../storage/istorage.dart';
import '../storage/mmkv_storage.dart';
import '../storage/storage_service.dart';
import 'app_router.dart';

// 全局 GetIt 实例
final GetIt locator = GetIt.instance;

// 初始化服务注册
void setupLocator() {
  // 懒加载注册 AppRouter 单例
  locator.registerLazySingleton<AppRouter>(() => AppRouter());

  locator.registerSingletonAsync<IStorage>(() async {
    await StorageService.init(); // 先初始化
    return StorageService.storage;
  });
}

GoRouter get appGoRouter => locator<AppRouter>().router;


// 获取 ObjectBox 存储实例
IStorage get storage => locator<IStorage>();