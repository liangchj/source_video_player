import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../commons/widget_style_commons.dart';
import '../models/app_media_file_model.dart';
import '../utils/time_format_utils.dart';

class MediaItemView extends StatefulWidget {
  const MediaItemView({
    super.key,
    required this.fileModel,
    this.leadingWidget,
    this.subtitleWidget,
    this.trailingWidget,
    this.onTap,
  });

  final AppMediaFileModel fileModel;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  State<MediaItemView> createState() => _MediaItemViewState();
}

class _MediaItemViewState extends State<MediaItemView> {
  AppMediaFileModel get fileModel => widget.fileModel;
  Widget? get leadingWidget => widget.leadingWidget;
  Widget? get subtitleWidget => widget.subtitleWidget;
  Widget? get trailingWidget => widget.trailingWidget;
  VoidCallback? get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: ListTile(
        horizontalTitleGap: WidgetStyleCommons.safeSpace / 2,
        contentPadding: EdgeInsets.only(
          left: WidgetStyleCommons.safeSpace,
          right: 0,
        ),
        leading: _buildLeadingWidget(context),
        title: _buildTitle(),
        subtitle: subtitleWidget,
        trailing: trailingWidget,
      ),
    );
  }

  _buildLeadingWidget(BuildContext context) {
    var duration = fileModel.assetEntity?.duration;
    return leadingWidget ??
        SizedBox(
          width: WidgetStyleCommons.mediaLeadingSize.width,
          height: WidgetStyleCommons.mediaLeadingSize.height,
          child: Stack(
            children: [
              Positioned.fill(child: _videoThumbnail()),
              if (fileModel.isLocal)
                Positioned(
                  bottom: WidgetStyleCommons.mediaLeadingRect.bottom,
                  right: WidgetStyleCommons.mediaLeadingRect.right,
                  child: Container(
                    padding: WidgetStyleCommons.mediaDurationPadding,
                    color: WidgetStyleCommons.mediaDurationBgColor,
                    child: duration == null
                        ? null
                        : Text(
                            TimeFormatUtils.durationToMinuteAndSecond(
                              Duration(seconds: duration),
                            ),
                            style: WidgetStyleCommons.mediaDurationTextStyle,
                          ),
                  ),
                ),
              if (fileModel.playHistoryDuration != null && duration != null)
                Positioned(
                  left: WidgetStyleCommons.mediaPlayProgressRect.left,
                  right: WidgetStyleCommons.mediaPlayProgressRect.right,
                  bottom: WidgetStyleCommons.mediaPlayProgressRect.bottom,
                  child: SizedBox(
                    height: WidgetStyleCommons.mediaPlayProgressHeight,
                    child: LinearProgressIndicator(
                      backgroundColor:
                          WidgetStyleCommons.mediaPlayProgressBgColor,
                      valueColor:
                          WidgetStyleCommons.mediaPlayProgressColorAnimation,
                      value:
                          fileModel.playHistoryDuration!.inSeconds / duration,
                    ),
                  ),
                ),
            ],
          ),
        );
  }

  Widget _videoThumbnail() {
    return FutureBuilder<Widget>(
      future: _buildVideoThumbnail(),
      builder: (context, snapshot) {
        return snapshot.data ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }

  // 构建视频缩略图
  Future<Widget> _buildVideoThumbnail() async {
    Uint8List? thumbnail;
    if (fileModel.thumbnailUint8List != null) {
      thumbnail = fileModel.thumbnailUint8List!;
    } else if (fileModel.assetEntity != null) {
      thumbnail = fileModel.assetEntity!.thumbnail;
    } else if (fileModel.file != null) {
      thumbnail = await fileModel.file!.readAsBytes();
    }
    return thumbnail == null
        ? const Icon(Icons.video_library)
        : Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            width: WidgetStyleCommons.mediaLeadingSize.width,
            height: WidgetStyleCommons.mediaLeadingSize.height,
          );
  }

  _buildTitle() {
    return Text(
      fileModel.fileName,
      maxLines: WidgetStyleCommons.mediaTitleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
