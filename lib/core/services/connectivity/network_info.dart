import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/constants/app_constants.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  // NetworkInfo({required Connectivity connectivity}) : _connectivity = connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return _hasInternetReachability();
  }

  Future<bool> _hasInternetReachability() async {
    final backendHost = Uri.tryParse(AppConstants.apiBaseUrl)?.host;
    final probes = <String>[
      if (backendHost != null && backendHost.isNotEmpty) backendHost,
      'example.com',
    ];

    try {
      for (final host in probes) {
        final result = await InternetAddress.lookup(host);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      }
      return false;
    } on SocketException {
      return false;
    }
  }
}
