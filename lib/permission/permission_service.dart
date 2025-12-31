import 'package:permission_handler/permission_handler.dart';

import 'permission_constants.dart';
import 'permission_controller.dart';

class PermissionService {
  /// 检查媒体库权限是否已授予
  /*Future<bool> checkMediaPermissions() async {
    final mediaPermissions = await getMediaPermissions();
    // 检查所有媒体相关权限
    Map<Permission, PermissionStatus> statuses = await mediaPermissions
        .request();
    // 所有权限都授予才算通过
    return statuses.values.every((status) => status.isGranted);
  }*/

  /// 仅检查权限状态，不主动请求
  Future<bool> hasMediaPermissions() async {
    final mediaPermissions = await getMediaPermissions();
    for (var permission in mediaPermissions) {
      if (await permission.status.isGranted == false) {
        return false;
      }
    }
    return true;
  }

  /// 主动发起媒体权限请求（核心：触发系统授权弹窗）
  Future<bool> requestMediaPermissions() async {
    final mediaPermissions = await getMediaPermissions();
    // 批量请求媒体相关权限，并获取请求结果
    Map<Permission, PermissionStatus> statuses = await mediaPermissions.request();
    // 所有媒体权限都授予才算请求成功
    return statuses.values.every((status) => status.isGranted);
  }

  /// 检查是否永久拒绝了权限
  Future<bool> isMediaPermissionPermanentlyDenied() async {
    final mediaPermissions = await getMediaPermissions();
    for (var permission in mediaPermissions) {
      if (await permission.status.isPermanentlyDenied) {
        return true;
      }
    }
    return false;
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 首次启动时请求媒体权限（非强制）
  Future<void> requestMediaPermissionOnFirstLaunch() async {
    final mediaPermissions = await getMediaPermissions();
    // 仅在首次启动时请求，不强制
    for (var permission in mediaPermissions) {
      var status = await permission.status;
      if (status.isDenied) {
        await permission.request();
        // break;
      }
    }
    PermissionController().initPermissions();
  }
}
