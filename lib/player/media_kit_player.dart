import 'package:flutter/material.dart';
import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

class MediaKitPlayer extends IPlayer {
  late final Player _player;
  late VideoController _videoController;
  MediaKitPlayer({super.playerViewModel}) {
    _player = Player();
    _videoController = VideoController(_player);
  }

  // 播放器初始化
  @override
  Future<void> onInitPlayer() async {
    try {
      /*_videoController.player.open(
        Media(playerViewModel?.playerState.playUrl),
        // Media("https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4"),
        play: playerViewModel?.playerState.autoPlay,
      );*/
      _videoController.player.setPlaylistMode(PlaylistMode.none);
      playerViewModel?.playerState.playerView.value = Watch(
        (context) => Video(
          controller: _videoController,
          fit: playerViewModel?.playerState.fit.value == null
              ? BoxFit.contain
              : BoxFit.values.firstWhere(
                  (e) =>
                      e.name == playerViewModel?.playerState.fit.value?.name,
                  orElse: () => BoxFit.contain,
                ),
          aspectRatio:
              playerViewModel?.playerState.aspectRatio.value ??
              playerViewModel?.playerState.videoAspectRatio,
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
      /*if (playerViewModel != null && playerViewModel!.initialized) {
        playerViewModel?.playerState.playerView.value = Container();
      }*/
    }
  }

  @override
  Future<void> onDisposePlayer() async {
    if (!playerViewModelDisposed && !playerStateDisposed) {
      playerViewModel?.playerState.playerView.value = Container();
    }
    if (disposed) {
      return;
    }
    try {
      await _player.dispose();
      disposed = true;
    } catch (_) {}
  }

  @override
  Future<void> play() async {
    if (disposed) {
      return;
    }
    return await _player.play();
  }

  @override
  Future<void> pause() async {
    if (disposed) {
      return;
    }
    return await _player.pause();
  }

  @override
  Future<void> stop() async {
    if (disposed) {
      return;
    }
    return await _player.stop();
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (disposed) {
      return;
    }
    if (!playerViewModelDisposed) {
      await playerViewModel?.beforeSeekTo();
    }
    await _player.seek(position);
    await for (final _ in _player.stream.position.take(1)) {}
    await Future.delayed(const Duration(milliseconds: 100));
    await for (final _ in _player.stream.position.take(1)) {}
    if (!playerViewModelDisposed) {
      await playerViewModel?.afterSeekTo();
    }
  }

  @override
  Future<void> setPlaySpeed(double speed) async {
    if (disposed) {
      return;
    }
    return await _player.setRate(speed);
  }

  @override
  bool get playing => disposed ? false : _player.state.playing;

  @override
  bool get buffering => disposed ? false : _player.state.buffering;

  @override
  bool get finished => disposed ? true : _player.state.completed;

  @override
  void updateState() {
    if (disposed) {
      return;
    }
    // 监听错误信息
    PlayerStream stream = _videoController.player.stream;

    stream.videoParams.listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      if (value.aspect != null) {
        playerViewModel?.playerState.videoAspectRatio = value.aspect!;
      }
    });
    stream.error.listen((String? error) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      // 视频是否加载错误
      playerViewModel?.playerState.errorMsg.value = error ?? "";
    });

    stream.duration.distinct().listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      if (value.compareTo(Duration.zero) != 0) {
        playerViewModel?.playerState.isInitialized.value = true;
      }
      playerViewModel?.playerState.duration.value = value;
    });

    stream.playing.listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      playerViewModel?.playerState.isPlaying.value = value;
      if (value) {
        playerViewModel?.playerState.errorMsg.value = "";
      }
    });

    stream.buffering.listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      playerViewModel?.playerState.isBuffering.value = value;
    });

    stream.completed.listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      playerViewModel?.playerState.isFinished.value = value;
    });

    stream.rate.listen((value) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      playerViewModel?.playerState.playSpeed.value = value;
    });

    // 监听进度
    stream.position.listen((Duration? position) {
      if (disposed || playerViewModelDisposed || playerStateDisposed) {
        return;
      }
      if (position != null &&
          playerViewModel != null &&
          !playerViewModel!.playerState.isSeeking.value &&
          !_videoController.player.state.buffering) {
        // 防抖：至少间隔 200ms 才更新
        DateTime now = DateTime.now();
        if (_lastPositionUpdate == null ||
            now.difference(_lastPositionUpdate!) >=
                Duration(milliseconds: 200)) {
          _lastPositionUpdate = now;
          var state = _videoController.player.state;
          bool isFinished = state.completed;
          // 监听是否播放完成
          playerViewModel?.playerState.isFinished.value = isFinished;

          if (isFinished) {
            playerViewModel?.playerState.positionDuration.value = position;
          } else {
            playerViewModel?.playerState.positionDuration.value = Duration(
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
    if (disposed || playerViewModelDisposed || playerStateDisposed || resourceDisposed) {
      return;
    }
    await _videoController.player.stop();
    if (playerViewModel != null &&
        playerViewModel?.resourceState.playingChapter != null &&
        (playerViewModel?.resourceState.playingChapter!.playUrl ?? "")
            .isNotEmpty) {
      try {
        Map<String, String> httpHeaders =
            playerViewModel?.resourceState.playingChapter!.httpHeaders ?? {};
        if (!httpHeaders.containsKey("user-agent")) {
          // httpHeaders["user-agent"] = DioUtils.getRandomUA();
        }
        await _videoController.player.open(
          Media(
            playerViewModel!.resourceState.playingChapter!.playUrl!,
            extras: playerViewModel?.resourceState.playingChapter!.extras,
            httpHeaders: httpHeaders,
            start: playerViewModel?.resourceState.playingChapter!.start,
          ),
          play: autoPlay,
        );
      } catch (e) {
        playerViewModel?.playerState.errorMsg.value = "播放链接异常：${e.toString()}";
      }
    } else {
      playerViewModel?.playerState.errorMsg.value = "播放链接为空";
    }
  }

  @override
  Future<void> dispose() async {
    if (disposed) {
      return;
    }
    _videoController.player.dispose();
    disposed = true;
  }

  @override
  IPlayer copyWith({PlayerViewModel? playerViewModel}) {
    return MediaKitPlayer(playerViewModel: playerViewModel);
  }
}
