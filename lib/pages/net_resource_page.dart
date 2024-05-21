
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/getx_controller/net_resource_controller.dart';

class NetResourcePage extends StatefulWidget {
  const NetResourcePage({super.key});

  @override
  State<NetResourcePage> createState() => _NetResourcePageState();
}

class _NetResourcePageState extends State<NetResourcePage> {
  final NetResourceController controller = Get.put(NetResourceController());
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("网络资源"),
    );
  }
}
