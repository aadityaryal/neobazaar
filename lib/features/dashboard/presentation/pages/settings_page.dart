import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/providers/device_sensor_provider.dart';
import 'package:neobazaar/core/services/sensors/device_sensor_models.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_audit_logs_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_audit_retention_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dashboard_heatmap_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dispute_decision_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_export_jobs_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_flags_triage_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_moderation_undo_page.dart';
import 'package:neobazaar/features/auth/presentation/pages/device_sessions_page.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorState = ref.watch(deviceSensorStateProvider);
    final settings = ref.watch(appSettingsProvider);
    final authState = ref.watch(authViewModelProvider);
    final capabilities = ref.watch(capabilityCacheProvider);
    final hasAdminAccess =
        capabilities.has('admin:all') || capabilities.has('admin:view');
    final modeSwitchEnabled = AppConstants.isFeatureEnabled(
      'buyer_seller_mode_switch',
    );
    final diagnosticsEnabled = AppConstants.isFeatureEnabled(
      'device_sensors_diagnostics',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Account & Mode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authState.authEntity?.fullName ?? 'Signed-in account'),
                  const SizedBox(height: 4),
                  Text(
                    authState.authEntity?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Profile is shared across Buyer, Seller, and Admin views.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Buyer'),
                      Switch(
                        value: settings.uiMode == UiMode.seller,
                        onChanged: modeSwitchEnabled
                            ? (enabled) {
                                final target = enabled
                                    ? UiMode.seller
                                    : UiMode.buyer;
                                ref
                                    .read(appSettingsProvider.notifier)
                                    .setUiMode(target);
                              }
                            : null,
                      ),
                      const Text('Seller'),
                    ],
                  ),
                  if (!modeSwitchEnabled)
                    Text(
                      'Buyer/Seller mode switching is currently disabled by feature flag.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Active: ${settings.uiMode.name}')),
                      if (hasAdminAccess)
                        const Chip(label: Text('Admin access')),
                      if (!hasAdminAccess)
                        const Chip(label: Text('Standard user access')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'App Preferences',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: settings.themeMode,
                    decoration: const InputDecoration(labelText: 'Theme'),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setThemeMode(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: settings.locale.languageCode,
                    decoration: const InputDecoration(labelText: 'Language'),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ne', child: Text('Nepali')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setLanguageCode(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: settings.shakeToThemeEnabled,
                    title: const Text('Shake to Toggle Theme'),
                    subtitle: const Text(
                      'Shake device to alternate light/dark mode.',
                    ),
                    onChanged: (enabled) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setShakeToThemeEnabled(enabled);
                    },
                  ),
                  SwitchListTile.adaptive(
                    value: settings.tiltRefreshEnabled,
                    title: const Text('Tilt Right-Left to Refresh'),
                    subtitle: const Text(
                      'Tilt right then left quickly to refresh home feed.',
                    ),
                    onChanged: (enabled) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setTiltRefreshEnabled(enabled);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeviceSessionsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.devices_outlined),
                      label: const Text('Manage Device Sessions'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasAdminAccess) ...[
            const SizedBox(height: 16),
            Text(
              'Admin Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: const Text('Heatmap Dashboard'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardHeatmapPage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('Flags Triage'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminFlagsTriagePage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history_outlined),
                    title: const Text('Audit Logs'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAuditLogsPage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Export Jobs'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminExportJobsPage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: const Text('Dispute Decision'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDisputeDecisionPage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.av_timer_outlined),
                    title: const Text('Audit Retention'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAuditRetentionPage(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.undo_outlined),
                    title: const Text('Moderation Undo'),
                    onTap: () {
                      if (AppRoutes.requireAdmin(context, ref)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminModerationUndoPage(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Device Diagnostics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (diagnosticsEnabled)
            _DeviceSensorsCard(sensorState: sensorState)
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Advanced diagnostics hidden by default'),
                subtitle: const Text(
                  'Sensor diagnostics are disabled for regular users. Enable feature flag `device_sensors_diagnostics` for advanced troubleshooting only.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceSensorsCard extends StatelessWidget {
  final AsyncValue<DeviceSensorState> sensorState;

  const _DeviceSensorsCard({required this.sensorState});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Device Sensors (3-axis)'),
        subtitle: Text(_statusText(sensorState)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          sensorState.when(
            data: (state) {
              if (state.status != DeviceSensorStatus.active ||
                  state.snapshot == null) {
                return Text(state.message ?? 'Sensors unavailable');
              }

              final snapshot = state.snapshot!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sensorLine('Accelerometer', snapshot.accelerometer),
                  const SizedBox(height: 4),
                  _sensorLine('Gyroscope', snapshot.gyroscope),
                  const SizedBox(height: 4),
                  _sensorLine('Magnetometer', snapshot.magnetometer),
                  const SizedBox(height: 8),
                  Text(
                    'Last update: ${snapshot.sampledAt.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (error, stackTrace) => Text('Sensor error: $error'),
          ),
        ],
      ),
    );
  }

  String _statusText(AsyncValue<DeviceSensorState> state) {
    return state.when(
      data: (value) {
        switch (value.status) {
          case DeviceSensorStatus.disabled:
            return 'Disabled';
          case DeviceSensorStatus.loading:
            return 'Loading';
          case DeviceSensorStatus.active:
            return 'Active';
          case DeviceSensorStatus.unavailable:
            return 'Unavailable';
        }
      },
      loading: () => 'Loading',
      error: (_, __) => 'Unavailable',
    );
  }

  Widget _sensorLine(String label, SensorVector vector) {
    String format(double value) => value.toStringAsFixed(2);

    return Text(
      '$label: x=${format(vector.x)} y=${format(vector.y)} z=${format(vector.z)}',
    );
  }
}
