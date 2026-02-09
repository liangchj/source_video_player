
//微软视频 ：wmv、asf、asx
//
//　　Real Player ：rm、 rmvb
//
//　　MPEG视频 ：mpg、mpeg、mpe
//
//　　手机视频 ：3gp
//
//　　Apple视频 ：mov
//
//　　Sony视频 ：mp4、m4v
//
//　　其他常见视频：avi、dat、mkv、flv、vob、f4v
enum FileFormat {
  video("视频文件", [
    "wmv",
    "asf",
    "asx",
    "rm",
    "rmvb",
    "mpg",
    "mpeg",
    "mpe",
    "3gp",
    "mov",
    "mp4",
    "m4v",
    "avi",
    "dat",
    "mkv",
    "flv",
    "vob",
    "f4v"
  ]),
  xml("xml文件",["xml"]);

  final String name;
  final List<String> formatList;
  const FileFormat(this.name, this.formatList);
}
