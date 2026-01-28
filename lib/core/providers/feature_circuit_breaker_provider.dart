import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureCircuitState {
  final int failureCount;
  final DateTime? openUntil;

  const FeatureCircuitState({this.failureCount = 0, this.openUntil});

  bool get isOpen => openUntil != null && openUntil!.isAfter(DateTime.now());

  FeatureCircuitState copyWith({int? failureCount, DateTime? openUntil}) {
    return FeatureCircuitState(
      failureCount: failureCount ?? this.failureCount,
      openUntil: openUntil,
    );
  }
}

class FeatureCircuitBreakerState {
  final Map<String, FeatureCircuitState> circuits;

  const FeatureCircuitBreakerState({
    this.circuits = const <String, FeatureCircuitState>{},
  });

  FeatureCircuitState forFeature(String feature) {
    return circuits[feature] ?? const FeatureCircuitState();
  }

  FeatureCircuitBreakerState copyWith({
    Map<String, FeatureCircuitState>? circuits,
  }) {
    return FeatureCircuitBreakerState(circuits: circuits ?? this.circuits);
  }
}

final featureCircuitBreakerProvider =
    NotifierProvider<FeatureCircuitBreakerNotifier, FeatureCircuitBreakerState>(
      FeatureCircuitBreakerNotifier.new,
    );

class FeatureCircuitBreakerNotifier
    extends Notifier<FeatureCircuitBreakerState> {
  static const int failureThreshold = 3;
  static const Duration coolDown = Duration(seconds: 45);

  @override
  FeatureCircuitBreakerState build() => const FeatureCircuitBreakerState();

  void recordFailure(String feature) {
    final current = state.forFeature(feature);
    final nextFailureCount = current.failureCount + 1;

    final next = <String, FeatureCircuitState>{...state.circuits};
    next[feature] = FeatureCircuitState(
      failureCount: nextFailureCount,
      openUntil: nextFailureCount >= failureThreshold
          ? DateTime.now().add(coolDown)
          : current.openUntil,
    );

    state = state.copyWith(circuits: next);
  }

  void recordSuccess(String feature) {
    final next = <String, FeatureCircuitState>{...state.circuits};
    next[feature] = const FeatureCircuitState();
    state = state.copyWith(circuits: next);
  }

  bool isOpen(String feature) {
    return state.forFeature(feature).isOpen;
  }
}
