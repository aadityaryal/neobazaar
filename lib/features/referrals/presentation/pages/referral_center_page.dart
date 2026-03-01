import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/core/utils/route_guards.dart';
import 'package:neobazaar/features/referrals/presentation/state/referral_center_state.dart';
import 'package:neobazaar/features/referrals/presentation/view_model/referral_center_notifier.dart';

class ReferralCenterPage extends ConsumerStatefulWidget {
  const ReferralCenterPage({super.key});

  @override
  ConsumerState<ReferralCenterPage> createState() => _ReferralCenterPageState();
}

class _ReferralCenterPageState extends ConsumerState<ReferralCenterPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _referredUserIdController =
      TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _referredUserIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(referralCenterNotifierProvider);
    final canManageReferrals = adminGuard(ref).allowed;

    return Scaffold(
      appBar: AppBar(title: const Text('Referrals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: canManageReferrals
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Create Referral Attribution'),
                          const SizedBox(height: 6),
                          const Text(
                            'Admin tools: create attribution and process pending referrals. Qualification credits +50 NeoTokens / +20 XP to referrer.',
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Referral code',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _referredUserIdController,
                            decoration: const InputDecoration(
                              labelText: 'Referred user id',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () {
                                ref
                                    .read(referralCenterNotifierProvider.notifier)
                                    .createReferral(<String, dynamic>{
                                      'code': _codeController.text.trim(),
                                      'referredUserId': _referredUserIdController
                                          .text
                                          .trim(),
                                    });
                              },
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Pending referrals and qualification are managed by admins.',
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: _buildBody(
              context,
              state,
              canManageReferrals: canManageReferrals,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReferralCenterState state, {
    required bool canManageReferrals,
  }) {
    final referrals = canManageReferrals
        ? state.referrals.where((item) {
            final status = item['status']?.toString().toLowerCase() ?? '';
            return status == 'pending' || status == 'open';
          }).toList(growable: false)
        : state.referrals;

    if (state.status == AsyncStatus.loading && state.referrals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AsyncStatus.error && state.referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? 'Unable to load referrals.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(referralCenterNotifierProvider.notifier)
                    .loadReferrals();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (referrals.isEmpty) {
      return Center(
        child: Text(
          canManageReferrals
              ? 'No pending referrals right now.'
              : 'No referrals available.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(referralCenterNotifierProvider.notifier)
            .loadReferrals();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: referrals.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final referral = referrals[index];
          final referralId =
              referral['referralId']?.toString() ??
              referral['id']?.toString() ??
              '';
          final title =
              referral['title']?.toString() ??
              referral['inviteeEmail']?.toString() ??
              'Referral ${index + 1}';
          final status = referral['status']?.toString() ?? 'pending';
          final isQualified = status.toLowerCase() == 'qualified';
          final isRewardCredited = _isRewardCredited(referral, isQualified);
          final rewardSource = _rewardSource(referral, isQualified);
          final rewardAt = _rewardTimestamp(referral);

          return ListTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $status'),
                if (isRewardCredited)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withAlpha(70)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Reward confirmed (+50 NeoTokens, +20 XP) • Source: $rewardSource${rewardAt == null ? '' : ' • At: $rewardAt'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: TextButton(
              onPressed: referralId.isEmpty || !canManageReferrals
                  ? null
                  : () {
                      ref
                          .read(referralCenterNotifierProvider.notifier)
                          .qualifyReferral(referralId);
                    },
              child: Text(canManageReferrals ? 'Qualify' : 'Admin only'),
            ),
          );
        },
      ),
    );
  }

  bool _isRewardCredited(Map<String, dynamic> referral, bool isQualified) {
    final rewardCredited = referral['rewardCredited'];
    if (rewardCredited is bool) {
      return rewardCredited;
    }

    final rewardStatus = referral['rewardStatus']?.toString().toLowerCase();
    if (rewardStatus == 'credited' || rewardStatus == 'completed') {
      return true;
    }

    return isQualified;
  }

  String _rewardSource(Map<String, dynamic> referral, bool isQualified) {
    final source =
        referral['rewardSource']?.toString() ??
        referral['qualifiedBy']?.toString() ??
        referral['creditedBy']?.toString();
    if (source != null && source.trim().isNotEmpty) {
      return source;
    }

    if (isQualified) {
      return 'system';
    }

    return 'pending';
  }

  String? _rewardTimestamp(Map<String, dynamic> referral) {
    final candidates = [
      referral['rewardCreditedAt'],
      referral['qualifiedAt'],
      referral['updatedAt'],
    ];

    for (final value in candidates) {
      final text = value?.toString();
      if (text != null && text.trim().isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}
