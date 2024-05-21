
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:source_video_player/getx_controller/personal_controller.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final PersonalController controller = Get.put(PersonalController());
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("个人中心"),
    );
  }
}
