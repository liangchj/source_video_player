import 'package:flutter/material.dart';

class WidgetStyleCommons {
  // 间距
  static double safeSpace = 12;

  // media item样式
  static int mediaTitleMaxLines = 2;

  // media leading尺寸
  static Size mediaLeadingSize = const Size(80, 60);
  // media 视频时长
  static Rect mediaLeadingRect = Rect.fromLTRB(0, 0, 0, 3);
  static EdgeInsetsGeometry mediaDurationPadding = EdgeInsets.symmetric(
    horizontal: 4,
  );
  static Color mediaDurationBgColor = Colors.black26.withValues(alpha: 0.5);
  static TextStyle mediaDurationTextStyle = TextStyle(color: Colors.white);

  // media 播放进度信息
  static Rect mediaPlayProgressRect = Rect.fromLTRB(0, 0, 0, 0);
  static double mediaPlayProgressHeight = 3;
  static Color mediaPlayProgressBgColor = Colors.grey.withValues(alpha: 0.5);
  static Animation<Color?> mediaPlayProgressColorAnimation =
      AlwaysStoppedAnimation<Color>(Colors.green);

  // media 右边图标样式
  static Widget mediaTrailingIcon = const Icon(Icons.more_vert_rounded);
  static EdgeInsetsGeometry mediaTrailingIconPadding =
      const EdgeInsets.symmetric(vertical: 8, horizontal: 10);

  // media 操作弹窗样式
  static EdgeInsetsGeometry mediaOperateBoxPadding = const EdgeInsets.symmetric(
    vertical: 10,
  );
  static Decoration mediaOperateBoxDecoration = const BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );
  static EdgeInsetsGeometry mediaOperateTitlePadding = const EdgeInsets.only(
    left: 16,
    top: 6,
    right: 16,
    bottom: 0,
  );
  static EdgeInsetsGeometry mediaOperateContentListPadding =
      const EdgeInsets.symmetric(vertical: 6, horizontal: 8);
  static ButtonStyle mediaOperateButtonStyle = ButtonStyle(
    alignment: Alignment.centerLeft,
    foregroundColor: WidgetStateProperty.all(Colors.black87),
  );
  // media 重命名 图标
  static Widget mediaOperateRenameIcon = const Icon(Icons.edit_rounded);
  // media 字幕 图标
  static Widget mediaOperateSubtitleIcon = const Icon(Icons.subtitles_rounded);
  // media 弹幕 图标
  static Widget mediaOperateDanmakuIcon = const Icon(Icons.subject_rounded);
  // media 添加到播放列表 图标
  static Widget mediaOperateAddToPlayDirectoryIcon = const Icon(
    Icons.playlist_play_rounded,
  );
  // media 播放 图标
  static Widget mediaOperatePlayIcon = const Icon(
    Icons.play_circle_fill_rounded,
  );
  // media 删除 图标
  static Widget mediaOperateDelIcon = const Icon(Icons.delete_rounded);

  // media mediaOperateAddToPlayDirectory 弹出操作栏 样式
  static EdgeInsetsGeometry mediaOperateAddToPlayDirectoryBoxPadding =
      const EdgeInsets.symmetric(vertical: 10, horizontal: 16);
  static Decoration mediaOperateAddToPlayDirectoryBoxDecoration =
      const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      );

  static Color mediaOperateAddToPlayDirectoryBoxBgColor = Colors.white;
  static ShapeBorder mediaOperateAddToPlayDirectoryBoxShapeBorder =
      RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10),
          topEnd: Radius.circular(10),
        ),
      );
  static EdgeInsetsGeometry mediaOperateAddToPlayDirectoryBtnPadding =
      const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 4);
}
