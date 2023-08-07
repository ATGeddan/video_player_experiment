import 'package:flutter/foundation.dart';

class DefaultChangeNotifier extends ChangeNotifier {
  bool loading = false;
  bool _disposed = false;
  String? errorMessage;
  Object? error;
  StackTrace? stackTrace;

  void toggleLoading({required bool on}) {
    if (loading != on) {
      loading = on;
      notifyListeners();
    }
  }

  void setErrorMessage(String? errorMessage) {
    if (this.errorMessage != errorMessage) {
      this.errorMessage = errorMessage;
      notifyListeners();
    }
  }

  void setError(Object error, {StackTrace? stackTrace}) {
    if (this.error != error) {
      this.error = error;
      if (this.stackTrace != stackTrace) this.stackTrace = stackTrace;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
