import 'package:flutter/material.dart';
import 'package:flutter_dynamic_api/flutter_dynamic_api.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';

import '../cache/current_configs.dart';
import '../view_model/net_resource_home_view_model.dart';

class ApiSelectListPage extends StatefulWidget {
  const ApiSelectListPage({super.key, required this.netResourceHomeViewModel});
  final NetResourceHomeViewModel netResourceHomeViewModel;

  @override
  State<ApiSelectListPage> createState() => _ApiSelectListPageState();
}

class _ApiSelectListPageState extends State<ApiSelectListPage> {
  NetResourceHomeViewModel get netResourceHomeViewModel =>
      widget.netResourceHomeViewModel;
  late ListObserverController observerController;
  late ScrollController scrollController;

  final Signal<ApiConfigModel?> _activeApi = Signal(null);

  @override
  void initState() {
    _activeApi.value = netResourceHomeViewModel.activatedApi.value;
    scrollController = ScrollController();
    observerController = ListObserverController();
    super.initState();
  }

  @override
  void dispose() {
    _activeApi.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("设置API"),
        actions: [
          TextButton(onPressed: () {}, child: Text("新增")),
          TextButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              CurrentConfigs.updateCurrentApi(_activeApi.value);
              netResourceHomeViewModel.activatedApi.value = _activeApi.value;
              Navigator.of(context).maybePop();
            },
            child: Text("确定"),
          ),
        ],
      ),
      body: Watch((context) {
        String currentApiName = _activeApi.value?.apiBaseModel.enName ?? "";
        return ListView.builder(
          itemCount: CurrentConfigs.enNameToApiMap.keys.length,
          itemBuilder: (ctx, index) {
            String key = CurrentConfigs.enNameToApiMap.keys.elementAt(index);
            var apiModel = CurrentConfigs.enNameToApiMap[key];
            return InkWell(
              onTap: () {
                _activeApi.value = apiModel;
              },
              child: ListTile(
                selectedColor: Colors.red,
                selected: key == currentApiName,
                leading: Opacity(
                  opacity: key == currentApiName ? 1.0 : 0.0,
                  child: Icon(Icons.check_outlined),
                ),
                title: Text(
                  apiModel?.apiBaseModel.name ?? key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // trailing: IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.edit_rounded),
                // ),
              ),
            );
          },
        );
      }),
    );
  }
}
