import 'package:flutter/material.dart';

class BottomSheetDialogUtils {
  static void openModalBottomSheet(
    Widget widget, {
    required BuildContext context,
    bool closeBtnShow = true,
    Color backgroundColor = Colors.white,
    bool isScrollControlled = false,
    bool isDismissible = true,
    RouteSettings? settings,
    Clip? clipBehavior,
    Color? barrierColor,
  }) {
    Widget bottomSheet = closeBtnShow
        ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: widget,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: backgroundColor,
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      TextButton(
                        onPressed: () {
                          //关闭对话框
                          closeModalBottomSheet();
                        },
                        child: Text("取消"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : widget;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      routeSettings: settings,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      builder: (context) => bottomSheet,
    );
  }

  static void closeModalBottomSheet() {
    /* bool open = Get.isBottomSheetOpen ?? false;
    if (open) {
      Get.closeAllBottomSheets();
    }*/
  }

  static void closeDialog({String? id}) {
    /*bool open = Get.isDialogOpen ?? false;
    if (open) {
      if (id == null) {
        Get.closeAllDialogs();
      } else {
        Get.closeDialog(id: id);
      }
    }*/
  }

  static void closeBottomSheetAndDialog({String? id}) {
    /*bool openBottomSheet = Get.isBottomSheetOpen ?? false;
    bool openDialog = Get.isDialogOpen ?? false;
    if (openBottomSheet || openDialog) {
      Get.closeAllDialogsAndBottomSheets(id);
    }*/
  }

  static void closeCurrentBottomSheet(BuildContext context) {
    try {
      // 尝试直接关闭当前的模态组件
      Navigator.of(context, rootNavigator: false).maybePop();
    } catch (e) {
      print("关闭失败: $e");
    }
  }
}
