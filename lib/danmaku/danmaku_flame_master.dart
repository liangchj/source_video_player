import 'package:flutter/material.dart';
import 'package:flutter_android_danmaku/flutter_android_danmaku.dart';
import 'package:flutter_jin_player/constants/logger_tag.dart';
import 'package:flutter_jin_player/flutter_jin_player.dart';
import 'package:get/get.dart';

class DanmakuFlameMaster extends IDanmaku {
  DanmakuViewController? danmakuController;

  // 烈焰弹幕使基本时长是3800毫秒
  final int baseDurationMs = 3800;
  // 初始化弹幕
  @override
  Widget? initDanmaku({bool? start}) {
    playerGetxController!.logger.d("初始化弹幕");
    return FlutterAndroidDanmakuView(
      onViewCreated: (c) {
        danmakuController = c;
      },
      danmakuOptions: getDanmakuOptions(start: start == null ? false : start),
    );
    // return Obx(() {
    //   // 显示区域
    //   int areaIndex =
    //       playerGetxController!.danmakuConfigOptions.danmakuArea.value.areaIndex;
    //   List<DanmakuAreaItem> danmakuAreaItemList = playerGetxController!
    //       .danmakuConfigOptions.danmakuArea.value.danmakuAreaItemList;
    //   double area = danmakuAreaItemList.isNotEmpty &&
    //           danmakuAreaItemList.length > areaIndex
    //       ? danmakuAreaItemList[areaIndex].area
    //       : 1.0;
    //   return AspectRatio(
    //     aspectRatio: area,
    //     child: FlutterAndroidDanmakuView(
    //       onViewCreated: (c) {
    //         danmakuController = c;
    //       },
    //       danmakuOptions: getDanmakuOptions(),
    //     ),
    //   );
    // });
  }

  DanmakuOptions getDanmakuOptions({bool start = false}) {
    // 显示区域
    // int areaIndex =
    //     playerGetxController!.danmakuConfigOptions.danmakuArea.value.areaIndex;
    // List<DanmakuAreaItem> danmakuAreaItemList = playerGetxController!
    //     .danmakuConfigOptions.danmakuArea.value.danmakuAreaItemList;
    // double area =
    //     danmakuAreaItemList.isNotEmpty && danmakuAreaItemList.length > areaIndex
    //         ? danmakuAreaItemList[areaIndex].area
    //         : 1.0;

    // 弹幕速度
    double second =
        playerGetxController!.danmakuConfigOptions.danmakuSpeed.value.speed /
            playerGetxController!.playConfigOptions.playSpeed.value;

    DanmakuOptions danmakuOptions = DanmakuOptions(
      androidDanmakuType: AndroidDanmakuType.akDanmaku,
      isStart: start,
      isShowCache: true,
      isShowFPS: true,
      danmakuPath: playerGetxController!
          .danmakuConfigOptions.danmakuSourceItem.value.path,
      danmakuAlphaRatio: playerGetxController!
              .danmakuConfigOptions.danmakuAlphaRatio.value.ratio /
          100.0,
      danmakuFontSizeRatio: playerGetxController!
              .danmakuConfigOptions.danmakuFontSize.value.ratio /
          100.0,
      // danmakuSpeed: second * 1000.0 / baseDurationMs,
      danmakuSpeed: baseDurationMs /
          ((playerGetxController?.playConfigOptions.playSpeed.value ?? 1.0) *
              (second * 1000)),
      danmakuStyleStroke: playerGetxController!
          .danmakuConfigOptions.danmakuStyleStrokeWidth.value.strokeWidth,
    );
    for (DanmakuFilterType filterType
        in playerGetxController!.danmakuConfigOptions.danmakuFilterTypeList) {
      switch (filterType.enName) {
        case "fixedTop":
          danmakuOptions.fixedTopDanmakuVisibility = !filterType.filter.value;
          break;

        case "fixedBottom":
          danmakuOptions.fixedBottomDanmakuVisibility =
              !filterType.filter.value;
          break;
        case "scroll":
          danmakuOptions.l2RDanmakuVisibility = !filterType.filter.value;
          danmakuOptions.r2LDanmakuVisibility = !filterType.filter.value;
          break;
        case "repeat":
          danmakuOptions.duplicateMergingEnable = !filterType.filter.value;
          break;
        case "color":
          danmakuOptions.colorsDanmakuVisibility = !filterType.filter.value;
          break;
      }
    }
    if (start &&
        playerGetxController!
                .playConfigOptions.positionDuration.value.inMilliseconds >
            0) {
      danmakuOptions.startPosition = playerGetxController!
          .playConfigOptions.positionDuration.value.inMilliseconds
          .toString();
    }
    return danmakuOptions;
  }

  @override
  void loadDanmakuByPath(String path,
      {bool fromAssets = false, bool start = false, int? startMs}) {
    // TODO: implement loadDanmakuByPath
  }

  // 发送弹幕
  @override
  void sendDanmaku(DanmakuItem danmakuItem) {
    danmakuController?.sendDanmaku(danmakuItem.content,
        time: danmakuItem.time < 0 ? null : danmakuItem.time.toString(),
        danmakuType: danmakuItem.mode,
        textSize: danmakuItem.fontSize,
        textColor: danmakuItem.color);
  }

  // 发送弹幕列表
  @override
  void sendDanmakuList(List<DanmakuItem> danmakuItemList) {
    for (DanmakuItem danmakuItem in danmakuItemList) {
      sendDanmaku(danmakuItem);
    }
  }

  // 启动弹幕
  @override
  Future<bool?> startDanmaku({int? startTime}) {
    playerGetxController!.logger.d("进入启动弹幕方法");
    if (!playerGetxController!.danmakuConfigOptions.initialized.value ||
        playerGetxController!.danmakuConfigOptions.danmakuView.value == null) {
      playerGetxController!.danmakuControl.initDanmaku();
    }

    try {
      playerGetxController!.logger.d("启动弹幕");
      int adjust = playerGetxController!
          .danmakuConfigOptions.adjustTime.value.seconds.inMilliseconds;
      danmakuController?.startDanmaku(startTime == null
          ? (playerGetxController!
                  .playConfigOptions.positionDuration.value.inMilliseconds +
              adjust)
          : startTime + adjust);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("启动弹幕失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}startDanmaku，启动弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 暂停弹幕
  @override
  Future<bool?> pauseDanmaku() {
    try {
      danmakuController?.pauseDanmaKu();
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("暂停弹幕失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}pauseDanmaku，暂停弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 继续弹幕
  @override
  Future<bool?> resumeDanmaku() {
    try {
      danmakuController?.resumeDanmaku();
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("继续弹幕失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}resumeDanmaku，继续弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 弹幕跳转
  @override
  Future<bool?> danmakuSeekTo(int time) {
    if (!playerGetxController!.playConfigOptions.initialized.value ||
        playerGetxController!.playConfigOptions.finished.value) {
      return Future.value(true);
    }
    try {
      danmakuController?.danmaKuSeekTo(time +
          playerGetxController!
              .danmakuConfigOptions.adjustTime.value.seconds.inMilliseconds);
      playerGetxController!.logger.d(
          "弹幕跳转毫秒${(time.seconds + playerGetxController!.danmakuConfigOptions.adjustTime.value.seconds).inMilliseconds.floor()}");
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("弹幕跳转失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}danmakuSeekTo，弹幕跳转失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 显示/隐藏弹幕
  @override
  Future<bool?> setDanmakuVisibility(bool visible) {
    if (!playerGetxController!.playConfigOptions.initialized.value ||
        playerGetxController!.playConfigOptions.finished.value) {
      return Future.value(true);
    }
    try {
      playerGetxController!.danmakuConfigOptions.visible(visible);
      // 如果设置显示弹幕，且视频已经初始化未播放结束，弹幕插件未初始化
      if (visible &&
          playerGetxController!.playConfigOptions.initialized.value &&
          !playerGetxController!.playConfigOptions.finished.value &&
          (!playerGetxController!.danmakuConfigOptions.initialized.value ||
              playerGetxController!.danmakuConfigOptions.danmakuView.value ==
                  null)) {
        playerGetxController!.danmakuControl.initDanmaku();
        // 视频正在播放，就需要播放弹幕
        if (playerGetxController!.playConfigOptions.playing.value) {
          playerGetxController!.danmakuControl.resumeDanmaku();
        }
      }
      danmakuController?.setDanmaKuVisibility(visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("显示/隐藏弹幕失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuVisibility，显示/隐藏弹幕失败：$e");
      return Future.value(false);
    }
    if (playerGetxController!.danmakuConfigOptions.visible.value != visible) {
      playerGetxController!.danmakuConfigOptions.visible(visible);
    }
    return Future.value(true);
  }

  // 设置弹幕透明的（百分比）
  @override
  Future<bool?> setDanmakuAlphaRatio(double danmakuAlphaRatio) {
    try {
      danmakuController?.setDanmakuAlphaRatio(
          danmakuAlphaRatio / 100.0 > 1.0 ? 1 : danmakuAlphaRatio / 100.0);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置弹幕透明度失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuAlphaRatio，设置弹幕透明度失败：$e");
      return Future.value(false);
    }
    if (playerGetxController!
            .danmakuConfigOptions.danmakuAlphaRatio.value.ratio !=
        danmakuAlphaRatio) {
      playerGetxController!.danmakuConfigOptions.danmakuAlphaRatio.value.ratio =
          danmakuAlphaRatio;
    }
    return Future.value(true);
  }

  // 设置弹幕显示区域
  @override
  Future<bool?> setDanmakuArea(double area, bool filter) {
    try {
      danmakuController?.setDanmakuDisplayArea(area);
      danmakuController?.setAllowOverlap(filter);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置弹幕显示区域失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuArea，设置弹幕显示区域失败：$e");
      return Future.value(false);
    }
    int areaIndex =
        playerGetxController!.danmakuConfigOptions.danmakuArea.value.areaIndex;
    List<DanmakuAreaItem> danmakuAreaItemList = playerGetxController!
        .danmakuConfigOptions.danmakuArea.value.danmakuAreaItemList;
    DanmakuAreaItem configItem = danmakuAreaItemList[areaIndex];

    if (configItem.area != area || configItem.filter != filter) {
      playerGetxController!.danmakuConfigOptions.danmakuArea.value.areaIndex =
          areaIndex;
    }
    return Future.value(true);
  }

  // 设置字体大小（百分比）
  @override
  Future<bool?> setDanmakuFontSize(double fontSizeRatio) {
    try {
      danmakuController?.setDanmakuFontSize(fontSizeRatio / 100);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置字体大小失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuFontSize，设置字体大小失败：$e");
      return Future.value(false);
    }
    if (playerGetxController!
            .danmakuConfigOptions.danmakuFontSize.value.ratio !=
        fontSizeRatio) {
      playerGetxController!.danmakuConfigOptions.danmakuFontSize.value.ratio =
          fontSizeRatio;
    }
    return Future.value(true);
  }

  // 设置描边
  @override
  Future<bool?> setDanmakuStyleStrokeWidth(double strokeWidth) {
    try {
      danmakuController?.setDanmakuStroke(strokeWidth);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置描边失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuStyleStrokeWidth，设置描边失败：$e");
      return Future.value(false);
    }
    if (playerGetxController!
            .danmakuConfigOptions.danmakuStyleStrokeWidth.value.strokeWidth !=
        strokeWidth) {
      playerGetxController!.danmakuConfigOptions.danmakuStyleStrokeWidth.value
          .strokeWidth = strokeWidth;
    }
    return Future.value(true);
  }

  // 设置滚动速度
  @override
  Future<bool?> setDanmakuSpeed(int durationMs, double playSpeed) {
    try {
      danmakuController
          ?.setDanmakuSpeed(baseDurationMs / (playSpeed * durationMs));
      debugPrint("设置速度：${(durationMs * 1000) / (playSpeed * baseDurationMs)}");
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置滚动速度失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setDanmakuSpeed，设置滚动速度失败：$e");
      return Future.value(false);
    }
    if (playerGetxController!.danmakuConfigOptions.danmakuSpeed.value.speed !=
        durationMs) {
      playerGetxController!.danmakuConfigOptions.danmakuSpeed.value.speed =
          durationMs.toDouble();
    }
    return Future.value(true);
  }

  // 设置是否启用合并重复弹幕
  @override
  Future<bool?> setDuplicateMergingEnabled(bool flag) {
    try {
      danmakuController?.setDuplicateMergingEnabled(!flag);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否启用合并重复弹幕失败：$e");
      playerGetxController!.logger.d(
          "${LoggerTag.danmakuLog}setDuplicateMergingEnabled，设置是否启用合并重复弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 设置是否显示顶部固定弹幕
  @override
  Future<bool?> setFixedTopDanmakuVisibility(bool visible) {
    try {
      danmakuController?.setFixedTopDanmakuVisibility(!visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否显示顶部固定弹幕失败：$e");
      playerGetxController!.logger.d(
          "${LoggerTag.danmakuLog}setFixedTopDanmakuVisibility，设置是否显示顶部固定弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 设置是否显示滚动弹幕
  @override
  Future<bool?> setRollDanmakuVisibility(bool visible) {
    try {
      danmakuController?.setL2RDanmakuVisibility(!visible);
      danmakuController?.setR2LDanmakuVisibility(!visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否显示滚动弹幕失败：$e");
      playerGetxController!.logger
          .d("${LoggerTag.danmakuLog}setRollDanmakuVisibility，设置是否显示滚动弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 设置是否显示底部固定弹幕
  @override
  Future<bool?> setFixedBottomDanmakuVisibility(bool visible) {
    try {
      danmakuController?.setFixedBottomDanmakuVisibility(!visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否显示底部固定弹幕失败：$e");
      playerGetxController!.logger.d(
          "${LoggerTag.danmakuLog}setFixedBottomDanmakuVisibility，设置是否显示底部固定弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 设置是否显示特殊弹幕
  @override
  Future<bool?> setSpecialDanmakuVisibility(bool visible) {
    try {
      danmakuController?.setSpecialDanmakuVisibility(!visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否显示特殊弹幕失败：$e");
      playerGetxController!.logger.d(
          "${LoggerTag.danmakuLog}setSpecialDanmakuVisibility，设置是否显示特殊弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 是否显示彩色弹幕
  @override
  Future<bool?> setColorsDanmakuVisibility(bool visible) {
    try {
      danmakuController?.setColorsDanmakuVisibility(!visible);
    } catch (e) {
      playerGetxController!.danmakuConfigOptions.errorMsg("设置是否显示彩色弹幕失败：$e");
      playerGetxController!.logger.d(
          "${LoggerTag.danmakuLog}setColorsDanmakuVisibility，设置是否显示彩色弹幕失败：$e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  // 清空弹幕
  @override
  void clearDanmaku() {}

  // 根据类型过滤弹幕
  @override
  void filterDanmakuType(DanmakuFilterType filterType) {
    switch (filterType.enName) {
      case "fixedTop":
        setFixedTopDanmakuVisibility(filterType.filter.value);
        break;
      case "fixedBottom":
        setFixedBottomDanmakuVisibility(filterType.filter.value);
        break;
      case "scroll":
        setRollDanmakuVisibility(filterType.filter.value);
        break;
      case "color":
        setColorsDanmakuVisibility(filterType.filter.value);
        break;
      case "repeat":
        setDuplicateMergingEnabled(filterType.filter.value);
        break;
    }
  }

  // 调整弹幕时间
  @override
  void danmakuAdjustTime(int adjustTime) {}

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
