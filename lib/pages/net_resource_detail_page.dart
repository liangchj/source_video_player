import 'package:flutter/material.dart';

import '../view_model/net_resource_detail_view_model.dart';

class NetResourceDetailPage extends StatefulWidget {
  const NetResourceDetailPage({super.key, required this.resourceId});
  final String resourceId;

  @override
  State<NetResourceDetailPage> createState() => _NetResourceDetailPageState();
}

class _NetResourceDetailPageState extends State<NetResourceDetailPage> {
  String get resourceId => widget.resourceId;
  late NetResourceDetailViewModel _viewModel;

  @override
  void initState() {
    _viewModel = NetResourceDetailViewModel(resourceId);
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
