/// Shared application state enum. One definition, used everywhere.
enum ViewState {
  idle,
  loading,
  success,
  empty,
  error,
}

extension ViewStateX on ViewState {
  bool get isLoading => this == ViewState.loading;
  bool get isEmpty => this == ViewState.empty;
  bool get isError => this == ViewState.error;
  bool get isReady => this == ViewState.success;
}