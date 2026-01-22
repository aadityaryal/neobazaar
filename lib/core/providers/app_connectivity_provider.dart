import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppConnectivityStatus { online, offline }

final appConnectivityProvider = StreamProvider<AppConnectivityStatus>((
  ref,
) async* {
  final connectivity = Connectivity();

  final initial = await connectivity.checkConnectivity();
  yield toAppConnectivityStatus(initial);

  await for (final changes in connectivity.onConnectivityChanged) {
    yield toAppConnectivityStatus(changes);
  }
});

AppConnectivityStatus toAppConnectivityStatus(
  List<ConnectivityResult> results,
) {
  if (results.contains(ConnectivityResult.none)) {
    return AppConnectivityStatus.offline;
  }
  return AppConnectivityStatus.online;
}
