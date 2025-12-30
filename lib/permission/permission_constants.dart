
import 'package:permission_handler/permission_handler.dart';

/// 媒体库相关权限
const List<Permission> mediaPermissions = [
  Permission.videos,  // 访问视频文件
  Permission.audio,   // 访问音频文件（可能包含弹幕）
  Permission.storage, // 通用存储权限，兼容旧版本
];

/// 权限设置页面路由
const String permissionSettingsRoute = '/permission-settings';

/// 权限相关提示文本
class PermissionTips {
  // 媒体库权限提示
  static const String mediaPermissionTitle = "需要媒体库权限";
  static const String mediaPermissionReason = "为了让您能够浏览和播放本地视频及弹幕文件，我们需要获取媒体库访问权限";
  static const String mediaPermissionDenied = "无法访问本地媒体库，您可以在设置中开启媒体权限";
  static const String mediaPermissionPermanentlyDenied = "媒体库权限已被永久拒绝，请在应用设置中手动开启";
}