import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../route/app_pages.dart';
import '../route/locator.dart';

class VideoCardWidget extends StatelessWidget {
  const VideoCardWidget({
    super.key,
    required this.videoModel,
    this.scoreWidget,
    this.cardNameWidget,
    this.otherWidget,
  });
  final VideoModel videoModel;

  /// 分数widget
  final Widget? scoreWidget;

  /// 卡片名称widget
  final Widget? cardNameWidget;

  /// 其他信息widget
  final Widget? otherWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        appRouter.push(AppPages.resourceDetailAndPlayerPage, extra: videoModel.id);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 图片信息
          Expanded(
            child: Stack(
              children: [
                _buildCoverWidget(),
                if (videoModel.score != null) createScoreWidget(),
              ],
            ),
          ),

          //名称
          cardNameWidget ??
              Container(
                margin: const EdgeInsets.only(top: 4.0),
                child: Text(
                  videoModel.name,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          otherWidget ?? Container(),
        ],
      ),
    );
  }

  Widget createScoreWidget() {
    return scoreWidget ??
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            color: Colors.green,
            child: Text(
              "${videoModel.score}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
  }

  Widget _buildCoverWidget() {
    /* return const Image(
        height: double.infinity,
        fit: BoxFit.fitHeight,
        image: AssetImage("assets/images/1.jpg"));*/
    return CachedNetworkImage(
      imageUrl: videoModel.coverUrl ?? "",
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) =>
          Center(child: const CircularProgressIndicator()),
      errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
    );

    /*if (videoModel.coverUrl == null || videoModel.coverUrl!.isEmpty) {
      return const Image(
          height: double.infinity,
          fit: BoxFit.fitHeight,
          image: AssetImage("assets/images/1.jpg"));
    }
    return Image.network(
      videoModel.coverUrl!,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? imageChunkEvent) {
        if (imageChunkEvent == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: imageChunkEvent.expectedTotalBytes != null
                ? imageChunkEvent.cumulativeBytesLoaded /
                    imageChunkEvent.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Image.asset(
          'assets/images/1.jpg', // 替换为你的错误图片路径
          fit: BoxFit.cover,
        );
      },
    );*/
  }
}
