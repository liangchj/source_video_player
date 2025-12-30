import 'package:signals/signals_core.dart';

import 'permission_service.dart';

class PermissionController {
  static final PermissionController _instance =
      PermissionController._internal();
  factory PermissionController() => _instance;
  PermissionController._internal();
  final PermissionService _permissionService = PermissionService();
  final Signal<bool> _hasMediaPermission = signal(false);

  bool get hasMediaPermission => _hasMediaPermission.value;

  /// 初始化权限状态
  Future<void> initPermissions() async {
    _hasMediaPermission.value = await _permissionService.hasMediaPermissions();
  }

  /// 检查并请求媒体权限
  Future<bool> checkAndRequestMediaPermission() async {
    bool hasPermission = await _permissionService.hasMediaPermissions();

    if (!hasPermission) {
      hasPermission = await _permissionService.checkMediaPermissions();
      _hasMediaPermission.value = hasPermission;
    }

    return hasPermission;
  }

  /// 检查是否永久拒绝了媒体权限
  Future<bool> checkMediaPermissionPermanentlyDenied() async {
    return await _permissionService.isMediaPermissionPermanentlyDenied();
  }

  /// 打开应用设置
  Future<bool> openAppSettings() async {
    bool result = await _permissionService.openAppSettings();
    // 从设置返回后重新检查权限
    if (result) {
      await initPermissions();
    }
    return result;
  }
}
