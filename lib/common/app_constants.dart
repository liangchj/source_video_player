import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class AppConstants {
  // 申请的权限
  static const List<Permission> permissionList = [
    Permission.storage,
    Permission.mediaLibrary,
    Permission.manageExternalStorage
  ];

  static const Color textColor = Colors.white;
  static const double textSize = 14;
  static const double titleTextSize = 16;
}
