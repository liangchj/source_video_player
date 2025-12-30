class LoadingStateModel<T> {
  bool loading;
  String? errorMsg;
  bool loadedSuc;
  bool isRefresh;
  T? data;
  LoadingStateModel({
    this.loading = true,
    this.errorMsg,
    this.loadedSuc = false,
    this.isRefresh = false,
    this.data,
  });

  LoadingStateModel copyWith({
    bool? loading,
    String? errorMsg,
    bool? loadedSuc,
    bool? isRefresh,
    T? data,
  }) {
    return LoadingStateModel(
      loading: loading ?? this.loading,
      errorMsg: errorMsg ?? this.errorMsg,
      loadedSuc: loadedSuc ?? this.loadedSuc,
      isRefresh: isRefresh ?? this.isRefresh,
      data: data ?? this.data,
    );
  }
}
