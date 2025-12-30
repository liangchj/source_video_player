import 'package:flutter/material.dart';
import 'permission_constants.dart';
import 'permission_controller.dart';

class PermissionRequestDialog extends StatelessWidget {
  final bool isPermanentlyDenied;
  final Function() onGranted;

  const PermissionRequestDialog({
    super.key,
    this.isPermanentlyDenied = false,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(PermissionTips.mediaPermissionTitle),
      content: Text(
        isPermanentlyDenied
            ? PermissionTips.mediaPermissionPermanentlyDenied
            : PermissionTips.mediaPermissionReason,
      ),
      actions: [
        TextButton(
          child: const Text("取消"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(isPermanentlyDenied ? "去设置" : "授予权限"),
          onPressed: () async {
            Navigator.pop(context);

            if (isPermanentlyDenied) {
              // 永久拒绝，打开设置
              bool result = await PermissionController()
                  .openAppSettings();
              if (result && PermissionController().hasMediaPermission) {
                onGranted();
              }
            } else {
              // 请求权限
              bool granted = await PermissionController().checkAndRequestMediaPermission();
              if (granted) {
                onGranted();
              }
            }
          },
        ),
      ],
    );
  }
}
