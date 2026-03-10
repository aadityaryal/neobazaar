import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_audit_logs_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_audit_retention_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dashboard_heatmap_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dispute_decision_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_export_jobs_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_flags_triage_page.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_moderation_undo_page.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/campaigns/presentation/pages/campaigns_management_page.dart';
import 'package:neobazaar/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:neobazaar/features/quests/presentation/pages/quests_page.dart';
import 'package:neobazaar/features/referrals/presentation/pages/referral_center_page.dart';
import 'package:neobazaar/features/risk/presentation/pages/risk_score_page.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadOverview);
  }

  Future<void> _loadOverview() async {
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);
    await Future.wait<void>([
      notifier.loadHeatmap(),
      notifier.loadUsers(),
      notifier.loadProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final heatmap = state.heatmap;
    final activeUsers = heatmap?['activeUsers'];
    final transactions = heatmap?['transactions'];
    final flagsTotal = heatmap?['flags'];
    final openFlagsCount = state.flags.length;
    final auditLogCount = state.auditLogs.length;
    final exportStatus = state.exportSnapshot?['status']?.toString() ?? 'unknown';
    final userCount = state.users.length;
    final productCount = state.products.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const OnboardingScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOverview,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (state.status == AsyncStatus.loading && heatmap == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.error != null && state.error!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Some admin data failed to load: ${state.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Text('Overview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricCard(label: 'Active Users', value: _metricText(activeUsers)),
                _MetricCard(
                  label: 'Transactions',
                  value: _metricText(transactions),
                ),
                _MetricCard(label: 'Flags (Heatmap)', value: _metricText(flagsTotal)),
                _MetricCard(
                  label: 'Open Flags',
                  value: openFlagsCount.toString(),
                ),
                _MetricCard(label: 'Users', value: userCount.toString()),
                _MetricCard(label: 'Products', value: productCount.toString()),
                _MetricCard(
                  label: 'Audit Logs',
                  value: auditLogCount.toString(),
                ),
                _MetricCard(label: 'Export Status', value: exportStatus),
              ],
            ),
            const SizedBox(height: 16),
            Text('Users (Latest)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: state.users.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No users loaded yet.'),
                    )
                  : Column(
                      children: state.users
                          .take(5)
                          .map(
                            (user) => ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(
                                user['name']?.toString() ??
                                    user['email']?.toString() ??
                                    'Unknown user',
                              ),
                              subtitle: Text(
                                'Role: ${user['role']?.toString() ?? 'user'} • ${user['email']?.toString() ?? '-'}',
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Products (Latest)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: state.products.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No products loaded yet.'),
                    )
                  : Column(
                      children: state.products
                          .take(5)
                          .map(
                            (product) => ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(
                                product['title']?.toString() ?? 'Untitled product',
                              ),
                              subtitle: Text(
                                'Price: ${product['priceListed'] ?? product['price'] ?? '-'} • Seller: ${product['sellerId']?.toString() ?? '-'}',
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _open(context, const CampaignsManagementPage()),
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('Campaigns'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _open(context, const QuestsPage()),
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Quests'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _open(context, const ReferralCenterPage()),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Pending Referrals'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Admin Tools', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.map_outlined,
                    title: 'Heatmap',
                    subtitle: 'Live system activity summary',
                    onTap: () => _open(context, const AdminDashboardHeatmapPage()),
                  ),
                  _NavTile(
                    icon: Icons.flag_outlined,
                    title: 'Flags Triage',
                    subtitle: 'Review and resolve moderation flags',
                    onTap: () => _open(context, const AdminFlagsTriagePage()),
                  ),
                  _NavTile(
                    icon: Icons.group_add_outlined,
                    title: 'Pending Referrals',
                    subtitle: 'Review and qualify pending referrals',
                    onTap: () => _open(context, const ReferralCenterPage()),
                  ),
                  _NavTile(
                    icon: Icons.shield_outlined,
                    title: 'Risk Score',
                    subtitle: 'Admin-only risk scoring panel',
                    onTap: () => _open(context, const RiskScorePage()),
                  ),
                  _NavTile(
                    icon: Icons.task_alt_outlined,
                    title: 'Quests',
                    subtitle: 'Create and manage quests',
                    onTap: () => _open(context, const QuestsPage()),
                  ),
                  _NavTile(
                    icon: Icons.campaign_outlined,
                    title: 'Campaigns',
                    subtitle: 'Create and manage campaigns',
                    onTap: () => _open(context, const CampaignsManagementPage()),
                  ),
                  _NavTile(
                    icon: Icons.download_outlined,
                    title: 'Export Jobs',
                    subtitle: 'Create and track export jobs',
                    onTap: () => _open(context, const AdminExportJobsPage()),
                  ),
                  _NavTile(
                    icon: Icons.gavel_outlined,
                    title: 'Dispute Decision',
                    subtitle: 'Resolve disputes',
                    onTap: () => _open(context, const AdminDisputeDecisionPage()),
                  ),
                  _NavTile(
                    icon: Icons.history_outlined,
                    title: 'Audit Logs',
                    subtitle: 'Inspect audit trail',
                    onTap: () => _open(context, const AdminAuditLogsPage()),
                  ),
                  _NavTile(
                    icon: Icons.auto_delete_outlined,
                    title: 'Audit Retention',
                    subtitle: 'Run retention policy actions',
                    onTap: () => _open(context, const AdminAuditRetentionPage()),
                  ),
                  _NavTile(
                    icon: Icons.undo_outlined,
                    title: 'Moderation Undo',
                    subtitle: 'Reverse moderation decisions',
                    onTap: () => _open(context, const AdminModerationUndoPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  static String _metricText(dynamic value) {
    if (value == null) {
      return '-';
    }
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
