class VideoBaseModel {
  // 资源id
  final String id;
  // 名称
  final String name;
  // 名称（英文名称或拼音）
  final String? enName;

  VideoBaseModel({required this.id, required this.name, required this.enName});

  factory VideoBaseModel.fromJson(Map<String, dynamic> json) {
    return VideoBaseModel(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      enName: json["enName"],
    );
  }
}
