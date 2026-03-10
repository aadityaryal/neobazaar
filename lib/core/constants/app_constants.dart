class AppConstants {
  AppConstants._();

  static const String appName = 'NeoBazaar';
  // Override for emulator/device networking, e.g. --dart-define=NB_LOCAL_BACKEND_HOST=10.0.2.2
  static const String localBackendHost = String.fromEnvironment(
    'NB_LOCAL_BACKEND_HOST',
    defaultValue: 'localhost',
  );
  static const int localBackendPort = 5050;
  static const String releaseChannel = String.fromEnvironment(
    'NB_RELEASE_CHANNEL',
    defaultValue: 'dev',
  );
  static const bool useMockBackend = bool.fromEnvironment(
    'NB_USE_MOCK_BACKEND',
    defaultValue: false,
  );
  static const bool useDemoBackend = bool.fromEnvironment(
    'NB_USE_DEMO_BACKEND',
    defaultValue: false,
  );

  static const bool flagRealtimeEnabled = bool.fromEnvironment(
    'NB_FLAG_REALTIME_ENABLED',
    defaultValue: true,
  );
  static const bool flagAiListingEnabled = bool.fromEnvironment(
    'NB_FLAG_AI_LISTING_ENABLED',
    defaultValue: true,
  );
  static const bool flagAdminExportEnabled = bool.fromEnvironment(
    'NB_FLAG_ADMIN_EXPORT_ENABLED',
    defaultValue: true,
  );
  static const bool flagRiskPanelEnabled = bool.fromEnvironment(
    'NB_FLAG_RISK_PANEL_ENABLED',
    defaultValue: true,
  );
  static const bool flagBuyerSellerModeSwitchEnabled = bool.fromEnvironment(
    'NB_FLAG_BUYER_SELLER_MODE_SWITCH_ENABLED',
    defaultValue: true,
  );
  static const bool flagDeviceSensorsEnabled = bool.fromEnvironment(
    'NB_FLAG_DEVICE_SENSORS_ENABLED',
    defaultValue: true,
  );
  static const bool flagDeviceSensorsDiagnosticsEnabled = bool.fromEnvironment(
    'NB_FLAG_DEVICE_SENSORS_DIAGNOSTICS_ENABLED',
    defaultValue: false,
  );

  static const Map<String, bool> productionFeatureFlags = <String, bool>{
    'realtime': true,
    'ai_listing': true,
    'admin_export': true,
    'risk_panel': true,
    'buyer_seller_mode_switch': true,
    'device_sensors': true,
    'device_sensors_diagnostics': false,
  };

  static String get apiBaseUrl {
    if (useMockBackend) {
      return 'http://$localBackendHost:$localBackendPort/mock/api';
    }

    if (useDemoBackend) {
      return 'http://$localBackendHost:$localBackendPort/demo/api';
    }

    switch (releaseChannel) {
      case 'prod':
        return 'https://api.neobazaar.com/api';
      case 'staging':
        return 'https://staging-api.neobazaar.com/api';
      case 'dev':
      default:
        return 'http://$localBackendHost:$localBackendPort/api';
    }
  }

  static String get apiBaseUrlV1 {
    if (useMockBackend) {
      return 'http://$localBackendHost:$localBackendPort/mock/api/v1';
    }

    if (useDemoBackend) {
      return 'http://$localBackendHost:$localBackendPort/demo/api/v1';
    }

    switch (releaseChannel) {
      case 'prod':
        return 'https://api.neobazaar.com/api/v1';
      case 'staging':
        return 'https://staging-api.neobazaar.com/api/v1';
      case 'dev':
      default:
        return 'http://$localBackendHost:$localBackendPort/api/v1';
    }
  }

  static const String headerRequestId = 'X-Request-Id';
  static const String headerIdempotencyKey = 'X-Idempotency-Key';

  static bool isFeatureEnabled(String key) {
    switch (key) {
      case 'realtime':
        return flagRealtimeEnabled;
      case 'ai_listing':
        return flagAiListingEnabled;
      case 'admin_export':
        return flagAdminExportEnabled;
      case 'risk_panel':
        return flagRiskPanelEnabled;
      case 'buyer_seller_mode_switch':
        return flagBuyerSellerModeSwitchEnabled;
      case 'device_sensors':
        return flagDeviceSensorsEnabled;
      case 'device_sensors_diagnostics':
        return flagDeviceSensorsDiagnosticsEnabled;
      default:
        return productionFeatureFlags[key] ?? false;
    }
  }
}
