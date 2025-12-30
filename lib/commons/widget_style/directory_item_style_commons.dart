import 'package:flutter/material.dart';

/// 目录item样式
class DirectoryItemStyleCommons {

  /// 默认LeadingWidget
  static Widget defaultLeadingWidget = const Padding(
    padding: EdgeInsets.only(right: 10),
    child: Icon(Icons.folder_rounded, size: 60, color: Colors.black26),
  );

  static int listTileTextMaxLines = 2;

  static int defaultSubtitleSize = 12;

  static TextStyle? defaultSubtitleStyle = const TextStyle(fontSize: 12);
}