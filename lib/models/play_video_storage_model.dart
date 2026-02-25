import 'dart:convert';

List<PlayVideoStorageModel> playVideoStorageModelListFromJson(String str) =>
    List<PlayVideoStorageModel>.from(
      json.decode(str).map((x) => PlayVideoStorageModel.fromJson(x)),
    );

String playVideoStorageModelListToJson(List<PlayVideoStorageModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlayVideoStorageModel {
  final String name;
  final String url;
  final String? assetId;
  final String? thumbUrl;

  PlayVideoStorageModel({
    required this.name,
    required this.url,
    this.assetId,
    this.thumbUrl,
  });

  factory PlayVideoStorageModel.fromJson(Map<dynamic, dynamic> json) {
    return PlayVideoStorageModel(
      name: json['name'],
      url: json['url'],
      assetId: json['assetId'],
      thumbUrl: json['thumbUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'assetId': assetId, 'thumbUrl': thumbUrl};
  }
}
