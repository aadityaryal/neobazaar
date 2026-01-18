import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalErrorBannerState {
  final bool visible;
  final String? message;

  const GlobalErrorBannerState({this.visible = false, this.message});

  GlobalErrorBannerState copyWith({bool? visible, String? message}) {
    return GlobalErrorBannerState(
      visible: visible ?? this.visible,
      message: message ?? this.message,
    );
  }
}

final globalErrorBannerProvider =
    NotifierProvider<GlobalErrorBannerNotifier, GlobalErrorBannerState>(
      GlobalErrorBannerNotifier.new,
    );

class GlobalErrorBannerNotifier extends Notifier<GlobalErrorBannerState> {
  @override
  GlobalErrorBannerState build() => const GlobalErrorBannerState();

  void show(String message) {
    state = GlobalErrorBannerState(visible: true, message: message);
  }

  void clear() {
    state = const GlobalErrorBannerState();
  }
}
