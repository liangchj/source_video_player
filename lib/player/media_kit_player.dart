import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

class MediaKitPlayer extends IPlayer {
  late final Player _player;
  late VideoController _videoController;
  MediaKitPlayer({super.playerController}) {
    _player = Player();
    _videoController = VideoController(_player);
  }

  // 播放器初始化
  @override
  Future<void> onInitPlayer() async {
    try {
      /*_videoController.player.open(
        Media(playerController?.playerState.playUrl),
        // Media("https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4"),
        play: playerController?.playerState.autoPlay,
      );*/
      _videoController.player.setPlaylistMode(PlaylistMode.none);
      playerController?.playerState.playerView.value = Watch(
        (context) => Video(
          controller: _videoController,
          fit: playerController?.playerState.fit.value == null
              ? BoxFit.contain
              : BoxFit.values.firstWhere(
                  (e) =>
                      e.name == playerController?.playerState.fit.value?.name,
                  orElse: () => BoxFit.contain,
                ),
          aspectRatio:
              playerController?.playerState.aspectRatio.value ??
              playerController?.playerState.videoAspectRatio,
          controls: (state) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              // body: Container(),
            );
          },
        ),
      );
      updateState();
    } catch (e) {
      /*if (playerController != null && playerController!.initialized) {
        playerController?.playerState.playerView.value = Container();
      }*/
    }
  }

  @override
  Future<void> onDisposePlayer() async {
    playerController?.playerState.playerView.value = Container();
    try {
      await _player.dispose();
    } catch (_) {}
  }

  @override
  Future<void> play() async {
    return await _player.play();
  }

  @override
  Future<void> pause() async {
    return await _player.pause();
  }

  @override
  Future<void> stop() async {
    return await _player.stop();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await playerController?.beforeSeekTo();
    await _player.seek(position);
    await for (final _ in _player.stream.position.take(1)) {}
    await Future.delayed(const Duration(milliseconds: 100));
    await for (final _ in _player.stream.position.take(1)) {}
    await playerController?.afterSeekTo();
  }

  @override
  Future<void> setPlaySpeed(double speed) async {
    return await _player.setRate(speed);
  }

  @override
  bool get playing => _player.state.playing;

  @override
  bool get buffering => _player.state.buffering;

  @override
  bool get finished => _player.state.completed;

  @override
  void updateState() {
    // 监听错误信息
    PlayerStream stream = _videoController.player.stream;

    stream.videoParams.listen((value) {
      if (value.aspect != null) {
        playerController?.playerState.videoAspectRatio = value.aspect!;
      }
    });
    stream.error.listen((String? error) {
      // 视频是否加载错误
      playerController?.playerState.errorMsg.value = error ?? "";
    });

    stream.duration.distinct().listen((value) {
      if (value.compareTo(Duration.zero) != 0) {
        playerController?.playerState.isInitialized.value = true;
      }
      playerController?.playerState.duration.value = value;
    });

    stream.playing.listen((value) {
      playerController?.playerState.isPlaying.value = value;
      if (value) {
        playerController?.playerState.errorMsg.value = "";
      }
    });

    stream.buffering.listen((value) {
      playerController?.playerState.isBuffering.value = value;
    });

    stream.completed.listen((value) {
      playerController?.playerState.isFinished.value = value;
    });

    stream.rate.listen(
      (value) => playerController?.playerState.playSpeed.value = value,
    );

    // 监听进度
    stream.position.listen((Duration? position) {
      if (position != null &&
          playerController != null &&
          !playerController!.playerState.isSeeking.value &&
          !_videoController.player.state.buffering) {
        // 防抖：至少间隔 200ms 才更新
        DateTime now = DateTime.now();
        if (_lastPositionUpdate == null ||
            now.difference(_lastPositionUpdate!) >= Duration(milliseconds: 200)) {
          _lastPositionUpdate = now;
          var state = _videoController.player.state;
          bool isFinished = state.completed;
          // 监听是否播放完成
          playerController?.playerState.isFinished.value = isFinished;

          if (isFinished) {
            playerController?.playerState.positionDuration.value = position;
          } else {
            playerController?.playerState.positionDuration.value = Duration(
              seconds: position.inSeconds,
            );
          }
        }
      }
    });
  }

  DateTime? _lastPositionUpdate;

  @override
  Future<void> changeVideoUrl({bool autoPlay = true}) async {
    await _videoController.player.stop();
    if (playerController != null &&
        playerController?.resourceState.playingChapter != null &&
        (playerController?.resourceState.playingChapter!.playUrl ?? "")
            .isNotEmpty) {
      try {
        Map<String, String> httpHeaders =
            playerController?.resourceState.playingChapter!.httpHeaders ?? {};
        if (!httpHeaders.containsKey("user-agent")) {
          // httpHeaders["user-agent"] = DioUtils.getRandomUA();
        }
        await _videoController.player.open(
          Media(
            playerController!.resourceState.playingChapter!.playUrl!,
            extras: playerController?.resourceState.playingChapter!.extras,
            httpHeaders: httpHeaders,
            start: playerController?.resourceState.playingChapter!.start,
          ),
          play: autoPlay,
        );
      } catch (e) {
        playerController?.playerState.errorMsg.value = "播放链接异常：${e.toString()}";
      }
    } else {
      playerController?.playerState.errorMsg.value = "播放链接为空";
    }
  }

  @override
  Future<void> dispose() async {
    _videoController.player.dispose();
  }

  @override
  IPlayer copyWith({PlayerController? playerController}) {
    return MediaKitPlayer(
      playerController: playerController,
    );
  }
}
