import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../controller/media_library_home_controller.dart';
import '../state/media_library_home_state.dart';

class MediaLibraryHomePage extends StatefulWidget {
  const MediaLibraryHomePage({super.key});

  @override
  State<MediaLibraryHomePage> createState() => _MediaLibraryHomePageState();
}

class _MediaLibraryHomePageState extends State<MediaLibraryHomePage> {
  late MediaLibraryHomeController _controller;
  MediaLibraryHomeState get state => _controller.state;
  @override
  void initState() {
    _controller = MediaLibraryHomeController()..init();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("媒体库")),
      body: ListView(children: state.libraryList.map((e) => e).toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SmartDialog.showToast('test toast ---- }');
        },
        tooltip: 'getVideo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
