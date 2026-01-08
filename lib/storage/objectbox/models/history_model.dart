import 'package:flutter_player_ui/flutter_player_ui.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class HistoryModel {
  @Id()
  int id;

  @Index()
  String databaseId;

  // 拆分 PlayHistoryModel 的所有字段
  String resourceId;
  String? apiKey;
  String? sourceGroupKey;
  String chapterUrl;
  int chapterIndex;
  String chapterName;
  int durationInMilli;
  int positionInMilli;
  DateTime time;

  HistoryModel({
    this.id = 0,
    required this.databaseId,
    required this.resourceId,
    this.apiKey,
    this.sourceGroupKey,
    required this.chapterUrl,
    required this.chapterIndex,
    required this.chapterName,
    required this.durationInMilli,
    required this.positionInMilli,
    required this.time,
  });

  HistoryModel copyWith({
    int? id,
    String? databaseId,
    String? resourceId,
    String? apiKey,
    String? sourceGroupKey,
    String? chapterUrl,
    int? chapterIndex,
    String? chapterName,
    int? durationInMilli,
    int? positionInMilli,
    DateTime? time,
  }) => HistoryModel(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    resourceId: resourceId ?? this.resourceId,
    apiKey: apiKey ?? this.apiKey,
    sourceGroupKey: sourceGroupKey ?? this.sourceGroupKey,
    chapterUrl: chapterUrl ?? this.chapterUrl,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    chapterName: chapterName ?? this.chapterName,
    durationInMilli: durationInMilli ?? this.durationInMilli,
    positionInMilli: positionInMilli ?? this.positionInMilli,
    time: time ?? this.time,
  );

  // 提供转换方法
  PlayHistoryModel toPlayHistoryModel() => PlayHistoryModel(
    resourceId: resourceId,
    apiKey: apiKey,
    sourceGroupKey: sourceGroupKey,
    chapterUrl: chapterUrl,
    chapterIndex: chapterIndex,
    chapterName: chapterName,
    durationInMilli: durationInMilli,
    positionInMilli: positionInMilli,
    time: time,
  );

  factory HistoryModel.fromPlayHistoryModel(PlayHistoryModel model) {
    return HistoryModel(
      databaseId: model.key,
      resourceId: model.resourceId,
      apiKey: model.apiKey,
      sourceGroupKey: model.sourceGroupKey,
      chapterUrl: model.chapterUrl,
      chapterIndex: model.chapterIndex,
      chapterName: model.chapterName,
      durationInMilli: model.durationInMilli,
      positionInMilli: model.positionInMilli,
      time: model.time,
    );
  }
}
