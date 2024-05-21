
import 'package:flutter/material.dart';
import 'package:source_video_player/model/directory_model.dart';

/// 目录组件
class DirectoryItemWidget extends StatelessWidget {
  const DirectoryItemWidget(
      {super.key,
        required this.directoryModel,
        this.leadingWidget,
        this.subtitleWidget,
        this.trailingWidget,
        this.onTap,
        this.contentPadding});

  final DirectoryModel directoryModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    Widget defaultLeadingWidget = const Padding(
      padding: EdgeInsets.only(right: 10),
      child: Icon(
        Icons.file_copy_rounded,
        size: 60,
        color: Colors.black26,
      ),
    );
    Widget defaultSubtitleWidget = Text(
      "${directoryModel.fileNumber}个视频",
      style: const TextStyle(fontSize: 12),
    );
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: contentPadding,
        leading: leadingWidget ?? defaultLeadingWidget,
        title: Text(
          directoryModel.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitleWidget ?? defaultSubtitleWidget,
        trailing: trailingWidget,
      ),
    );
  }
}
