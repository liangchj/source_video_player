
class TimeFormatUtils {
  /// 时间转换为分秒(分:秒)
  static String durationToMinuteAndSecond(Duration duration) {
    int seconds = duration.inSeconds;
    return secondToMinuteAndSecond(seconds);
  }

  /// 秒数转换为分秒(分:秒)
  static String secondToMinuteAndSecond(int seconds) {
    if (seconds < 0) {
      return "00:00";
    }
    int m = (seconds / 60).truncate();
    int s = seconds - m * 60;
    return "${m < 10 ? '0' : ''}$m:${s < 10 ? '0' : ''}$s";
  }

}