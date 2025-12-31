import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:source_video_player/view_model/media_library_home_view_model.dart';

import '../state/media_library_home_state.dart';

class MediaLibraryHomePage extends StatefulWidget {
  const MediaLibraryHomePage({super.key});

  @override
  State<MediaLibraryHomePage> createState() => _MediaLibraryHomePageState();
}

class _MediaLibraryHomePageState extends State<MediaLibraryHomePage> {
  late MediaLibraryHomeViewModel viewModel;
  MediaLibraryHomeState get state => viewModel.state;
  @override
  void initState() {
    viewModel = MediaLibraryHomeViewModel();

    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
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
