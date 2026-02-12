import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PublicCommons {
  static Logger logger = Logger();

  /// api json文件存储路径
  static String apiJsonFilePath = "assets/net_api/net_api.json";

  /// 网络加载超时时间（毫秒）
  static Duration netLoadTimeOutDuration = Duration(milliseconds: 60000);

  // 下拉刷新距离
  static double refreshDisplacement = 20.0;
  static double refreshDragPercentage = 0.25;


  // 权限
  static List<Permission> permissionList = [
    Permission.storage,
    Permission.mediaLibrary,
    Permission.videos,
    Permission.sensors,
    Permission.notification,
    Permission.accessNotificationPolicy,
    Permission.accessMediaLocation,
    Permission.activityRecognition,
    Permission.manageExternalStorage,
  ];

  static List<Permission> requiredPermissionList = [
    Permission.videos,
    Permission.manageExternalStorage,
  ];
}
