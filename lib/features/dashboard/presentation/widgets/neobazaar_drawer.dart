import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/utils/route_guards.dart';
import 'package:neobazaar/features/auth/presentation/pages/login_screen.dart';
import 'package:neobazaar/features/campaigns/presentation/pages/campaigns_management_page.dart';
import 'package:neobazaar/features/chat/presentation/pages/chat_inbox_page.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/settings_page.dart';
import 'package:neobazaar/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:neobazaar/features/notifications/presentation/pages/notifications_center_page.dart';
import 'package:neobazaar/features/quests/presentation/pages/quests_page.dart';
import 'package:neobazaar/features/referrals/presentation/pages/referral_center_page.dart';
import 'package:neobazaar/features/risk/presentation/pages/risk_score_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/offers_inbox_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/orders_list_page.dart';
import 'package:neobazaar/features/trade/presentation/pages/transaction_history_page.dart';
import 'package:neobazaar/features/wallet/presentation/pages/wallet_topup_page.dart';

class NeoBazaarDrawer extends ConsumerWidget {
  const NeoBazaarDrawer({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = adminGuard(ref).allowed;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E293B)),
            child: Text(
              'NeoBazaar Menu',
              style: TextStyle(
                color: Color(0xFFFF9933),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chats'),
            onTap: () {
              _openPage(
                context,
                Scaffold(
                  appBar: AppBar(title: const Text('Chats')),
                  body: const ChatInboxPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt_outlined),
            title: const Text('Quests'),
            onTap: () => _openPage(context, const QuestsPage()),
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Referrals'),
              onTap: () => _openPage(context, const ReferralCenterPage()),
            ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => _openPage(context, const NotificationsCenterPage()),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Leaderboard'),
            onTap: () => _openPage(context, const LeaderboardPage()),
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Campaigns'),
              onTap: () =>
                  _openPage(context, const CampaignsManagementPage()),
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Risk Score'),
              onTap: () => _openPage(context, const RiskScorePage()),
            ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Wallet'),
            onTap: () => _openPage(context, const WalletTopupPage()),
          ),
          ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: const Text('Trade Offers'),
            onTap: () => _openPage(context, const OffersInboxPage()),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Trade Orders'),
            onTap: () => _openPage(context, const OrdersListPage()),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Trade History'),
            onTap: () => _openPage(context, const TransactionHistoryPage()),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _openPage(context, const SettingsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
