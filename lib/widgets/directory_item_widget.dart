import 'package:flutter/material.dart';

import '../commons/widget_style/directory_item_style_commons.dart';
import '../models/app_directory_model.dart';

/// 目录widget
class DirectoryItemWidget extends StatelessWidget {
  const DirectoryItemWidget({
    super.key,
    required this.directoryModel,
    this.leadingWidget,
    this.subtitleWidget,
    this.trailingWidget,
    this.onTap,
    this.contentPadding,
  });

  final AppDirectoryModel directoryModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    Widget defaultSubtitleWidget = Text(
      "${directoryModel.fileNumber}个视频",
      style: DirectoryItemStyleCommons.defaultSubtitleStyle,
    );
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: contentPadding,
        leading:
            leadingWidget ?? DirectoryItemStyleCommons.defaultLeadingWidget,
        title: Text(
          directoryModel.name,
          maxLines: DirectoryItemStyleCommons.listTileTextMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitleWidget ?? defaultSubtitleWidget,
        trailing: trailingWidget,
      ),
    );
  }
}
