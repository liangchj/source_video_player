import 'package:flutter/material.dart';
import 'package:source_video_player/model/file_model.dart';
import 'package:source_video_player/utils/date_utils.dart';

/// 文件widget
class FileItemWidget extends StatelessWidget {
  const FileItemWidget(
      {super.key,
      required this.fileModel,
      this.leadingWidget,
      this.subtitleWidget,
      this.trailingWidget,
      this.onTap});
  final FileModel fileModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget defaultLeadingWidget = const Padding(
      padding: EdgeInsets.only(right: 10),
      child: Icon(
        Icons.file_copy_rounded,
        size: 40,
        color: Colors.black26,
      ),
    );

    /// 弹幕和字幕信息
    List<Widget> subtitleList = [];
    if (fileModel.danmakuPath != null && fileModel.danmakuPath!.isNotEmpty) {
      subtitleList.add(const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 8,
          child: Text("弹", style: TextStyle(fontSize: 10))));
    }
    if (fileModel.subtitlePath != null && fileModel.subtitlePath!.isNotEmpty) {
      subtitleList.add(const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 8,
          child: Text("字", style: TextStyle(fontSize: 10))));
    }
    if (subtitleList.isEmpty) {
      // barrageSubtitleList.add(Container(width: 0,));
    }
    subtitleList
        .add(Text(DateTimeUtils.ymdhmsFormatter.format(fileModel.modTime)));

    Widget defaultSubtitleWidget = Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: subtitleList.map((e) => e).toList(),
      ),
    );
    return InkWell(
      onTap: () => onTap?.call(),
      child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        leading: leadingWidget ?? defaultLeadingWidget,
        title: Text(
          fileModel.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitleWidget ?? defaultSubtitleWidget,
        trailing: trailingWidget,
      ),
    );
  }
}
