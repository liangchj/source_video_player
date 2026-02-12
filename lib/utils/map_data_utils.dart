
import 'package:intl/intl.dart';

class MapDataUtils {

  static final List<String> dateTimeFormats = [
    "yyyy-MM-dd HH:mm:ss.SSS",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy-MM-dd HH:mm",
    "yyyy-MM-dd HH",
    "yyyy-MM-dd",
    "yyyy/MM/dd HH:mm:ss.SSS",
    "yyyy/MM/dd HH:mm:ss",
    "yyyy/MM/dd HH:mm",
    "yyyy/MM/dd HH",
    "yyyy/MM/dd",
    "yyyy.MM.dd HH:mm:ss.SSS",
    "yyyy.MM.dd HH:mm:ss",
    "yyyy.MM.dd HH:mm",
    "yyyy.MM.dd HH",
    "yyyy.MM.dd",
    "yyyyMMdd HH:mm:ss.SSS",
    "yyyyMMdd HH:mm:ss",
    "yyyyMMdd HH:mm",
    "yyyyMMdd HH",
    "yyyyMMdd",
    "yyyy年MM月dd日 HH:mm:ss.SSS",
    "yyyy年MM月dd日 HH:mm:ss",
    "yyyy年MM月dd日 HH:mm",
    "yyyy年MM月dd日 HH",
    "yyyy年MM月dd日",
    "yyyy年MM月dd日 HH时mm分ss秒SSS毫秒",
    "yyyy年MM月dd日 HH时mm分ss秒",
    "yyyy年MM月dd日 HH时mm分",
    "yyyy年MM月dd日 HH时",
    "yyyy年MM月dd日",
    "yyyy年MM月dd日 HH小时mm分钟ss秒SSS毫秒",
    "yyyy年MM月dd日 HH小时mm分钟ss秒",
    "yyyy年MM月dd日 HH小时mm分钟",
    "yyyy年MM月dd日 HH小时",
    "yyyy年MM月dd日 HH小时mm分ss秒SSS毫秒",
    "yyyy年MM月dd日 HH小时mm分ss秒",
    "yyyy年MM月dd日 HH小时mm分",
    "yyyy年MM月dd日 HH\"h\"mm\"m\"ss\"s\"",
    "yyyy年MM月dd日 HH\"h\"mm\"m\"",
    "yyyy年MM月dd日 HH\"h\"",
  ];

  static final List<String> durationDateTimeFormats = [
    "dd",
    "dd日",
    "dd天",
    "dd HH:mm:ss.SSS",
    "dd HH:mm:ss",
    "dd HH:mm",
    "dd HH",
    "dd",
    "dd HH\"h\"mm\"m\"ss\"s\"",
    "dd HH\"h\"mm\"m\"",
    "dd HH\"h\"",
    "dd日 HH:mm:ss.SSS",
    "dd日 HH:mm:ss",
    "dd日 HH:mm",
    "dd日 HH",
    "dd日",
    "dd日 HH\"h\"mm\"m\"ss\"s\"",
    "dd日 HH\"h\"mm\"m\"",
    "dd日 HH\"h\"",
    "dd日 HH时mm分ss秒SSS毫秒",
    "dd日 HH时mm分ss秒",
    "dd日 HH时mm分",
    "dd日 HH时",
    "dd天 HH:mm:ss.SSS",
    "dd天 HH:mm:ss",
    "dd天 HH:mm",
    "dd天 HH",
    "dd天",
    "dd天 HH\"h\"mm\"m\"ss\"s\"",
    "dd天 HH\"h\"mm\"m\"",
    "dd天 HH\"h\"",
    "dd天 HH时mm分ss秒SSS毫秒",
    "dd天 HH时mm分ss秒",
    "dd天 HH时mm分",
    "dd天 HH时",
    "dd日 HH时mm分钟ss秒SSS毫秒",
    "dd日 HH时mm分钟ss秒",
    "dd日 HH时mm分钟",
    "dd天 HH时mm分钟ss秒SSS毫秒",
    "dd天 HH时mm分钟ss秒",
    "dd天 HH时mm分钟",

    "HH:mm:ss.SSS",
    "HH:mm:ss",
    "HH:mm",
    "HH",
    "dd",
    "HH\"h\"mm\"m\"ss\"s\"",
    "HH\"h\"mm\"m\"",
    "HH\"h\"",
    "HH:mm:ss.SSS",
    "HH:mm:ss",
    "HH:mm",
    "HH",
    "dd日",
    "HH\"h\"mm\"m\"ss\"s\"",
    "HH\"h\"mm\"m\"",
    "HH\"h\"",
    "HH时mm分ss秒SSS毫秒",
    "HH时mm分ss秒",
    "HH时mm分",
    "HH时",
    "HH:mm:ss.SSS",
    "HH:mm:ss",
    "HH:mm",
    "HH",
    "dd天",
    "HH\"h\"mm\"m\"ss\"s\"",
    "HH\"h\"mm\"m\"",
    "HH\"h\"",
    "HH时mm分ss秒SSS毫秒",
    "HH时mm分ss秒",
    "HH时mm分",
    "HH时",
    "HH时mm分钟ss秒SSS毫秒",
    "HH时mm分钟ss秒",
    "HH时mm分钟",
    "HH时mm分钟ss秒SSS毫秒",
    "HH时mm分钟ss秒",
    "HH时mm分钟",

    "mm:ss.SSS",
    "mm:ss",
    "mm",
    "mm\"m\"ss\"s\"",
    "mm\"m\"",
    "mm分ss秒SSS毫秒",
    "mm分ss秒",
    "mm分",
    "mm分钟ss秒SSS毫秒",
    "mm分钟ss秒",
    "mm分钟",

    "ss.SSS",
    "ss",
    "ss\"s\"",
    "ss秒SSS毫秒",
    "ss秒",
  ];

  // 提取第一个数值（整数或小数）
  static String? extractFirstNumericValue(String input) {
    final regex = RegExp(r'[-+]?\d*\.?\d+');
    final match = regex.firstMatch(input);
    return match?.group(0);
  }

  // 提取所有数值（整数或小数）
  static List<String> extractAllNumericValues(String input) {
    final regex = RegExp(r'[-+]?\d*\.?\d+');
    return regex.allMatches(input).map((m) => m.group(0)!).toList();
  }

  // 从map中获取指定key对应的值，并返回double
  static double? getDoubleFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    double? d = double.tryParse(str);
    if (d != null) {
      return d;
    }
    var numStr = extractFirstNumericValue(str);
    return numStr == null ? null : double.tryParse(numStr);

  }
  // 从map中获取指定key对应的值，并返回Duration
  // 当内容为纯数字时默认表示分钟数
  static Duration? getDurationFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    double? d = double.tryParse(str);
    if (d != null) {
      return Duration(milliseconds: (d * 60 * 1000).ceil());
    }
    Duration? duration;
    DateTime? dateTime;
    String errorMsg = "";

    try {
      dateTime = DateTime.parse(str);
    } catch (e) {
      errorMsg = e.toString();
      for (var item in durationDateTimeFormats) {
        if (item.length != str.length) {
          continue;
        }
        if ((!str.contains(":") && item.contains(":"))
            || (!str.contains("h") && item.contains("h"))
            || (!str.contains("时") && item.contains("时"))
            || (!str.contains("小时") && item.contains("小时"))
            || (!str.contains("日") && item.contains("日"))
            || (!str.contains("天") && item.contains("天"))
        ) {
          continue;
        }
        try {
          dateTime = DateFormat(item).parse(str);
          errorMsg = "";
        } catch (e1) {
          errorMsg = e1.toString();
        }
      }
    }
    if (dateTime == null && errorMsg.isNotEmpty) {
      throw Exception("将json数据中的[$key]：$str转换为DateTime类型报错：$errorMsg");
    }
    if (dateTime != null) {
      duration = Duration(milliseconds: dateTime.millisecondsSinceEpoch);
    }
    return duration;
  }

  // 从map中获取指定key对应的值，并返回int
  static int? getIntFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }
    var numStr = extractFirstNumericValue(str);
    if (numStr == null) {
      return null;
    }
    try {
      var parse = int.parse(numStr);
      return parse;
    } catch (e) {
      throw Exception("将json数据中的[$key]：$str转换为int类型报错：$e");
    }
  }

  // 从map中获取指定key对应的值，并返回List<String>
  static List<String> getListFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value != null) {
      String str = value.toString().trim();
      if (str.isEmpty) {
        return [];
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else {
        return value.toString().split(",");
      }
    } else {
      return [];
    }
  }


  // 从map中获取指定key对应的值，并返回DateTime
  static DateTime? getDateTimeFromMap(Map<String, dynamic> map, String key) {
    var value = map[key];
    if (value == null) {
      return null;
    }
    String str = value.toString().trim();
    if (str.isEmpty) {
      return null;
    }

    // 纯数字就可能是时间戳
    if (int.tryParse(str) != null) {
      if (str.length == 13) {
        // 毫秒时间戳
        return DateTime.fromMillisecondsSinceEpoch(int.parse(str));
      }
      if (str.length == 16) {
        // 微秒
        return DateTime.fromMicrosecondsSinceEpoch(int.parse(str));
      }
      if (str.length == 10) {
        // 秒时间戳
        return DateTime.fromMillisecondsSinceEpoch(int.parse(str) * 1000);
      }
      throw Exception("将json数据中的[$key]：$str 为纯数字且不是有效的时间戳");
    }
    DateTime? dateTime;
    String errorMsg = "";
    try {
      dateTime = DateTime.parse(str);
    } catch (e) {
      errorMsg = e.toString();
      for (var item in dateTimeFormats) {
        if (item.length != str.length) {
          continue;
        }
        if ((!str.contains("-") && item.contains("-"))
            || (!str.contains("/") && item.contains("/"))
            || (!str.contains(".") && item.contains("."))
            || (!str.contains("年") && item.contains("年"))
        ) {
          continue;
        }
        try {
          dateTime = DateFormat(item).parse(str);
          errorMsg = "";
        } catch (e1) {
          errorMsg = e1.toString();
        }
      }
    }
    if (dateTime == null && errorMsg.isNotEmpty) {
      throw Exception("将json数据中的[$key]：$str转换为DateTime类型报错：$errorMsg");
    }
    return dateTime;
  }

}