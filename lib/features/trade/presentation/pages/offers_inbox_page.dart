import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/presentation/view_model/offer_notifier.dart';

class OffersInboxPage extends ConsumerStatefulWidget {
  const OffersInboxPage({super.key});

  @override
  ConsumerState<OffersInboxPage> createState() => _OffersInboxPageState();
}

class _OffersInboxPageState extends ConsumerState<OffersInboxPage> {
  void _showBlockedActionMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(offerNotifierProvider.notifier).fetchInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offerNotifierProvider);
    final notifier = ref.read(offerNotifierProvider.notifier);
    final session = ref.watch(appSessionProvider);
    final capabilities = ref.watch(capabilityCacheProvider);

    final currentUserId = session.user?.authId;
    final isAdmin =
        capabilities.has('role:admin') ||
        capabilities.has('admin:access') ||
        capabilities.has('admin:*');

    final scopedOffers = currentUserId == null
        ? state.offers
        : state.offers.where((offer) {
            if (isAdmin) {
              return true;
            }
            return offer.buyerId == currentUserId ||
                offer.sellerId == currentUserId;
          }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Offers Inbox')),
      body: state.status == AsyncStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (scopedOffers.isEmpty)
                  const Text('No offers available for this account.'),
                ...scopedOffers.map(
                  (offer) {
                    final userIsSeller =
                        currentUserId != null && offer.sellerId == currentUserId;
                    final userIsBuyer =
                        currentUserId != null && offer.buyerId == currentUserId;
                  final isMutableStatus =
                    offer.status == 'pending' || offer.status == 'countered';
                  final mutationBlockedReason = currentUserId == null
                    ? 'Log in to manage offers.'
                    : !userIsSeller
                    ? (userIsBuyer
                        ? 'Only the seller can counter, accept, or reject this offer.'
                        : isAdmin
                        ? 'Admin can review offers, but only the seller account can change status.'
                        : 'This offer is not owned by your account.')
                    : !isMutableStatus
                    ? 'This offer is already ${offer.status} and cannot be changed.'
                    : null;
                  final canMutate = mutationBlockedReason == null;
                    final perspective = isAdmin
                        ? 'admin'
                        : (userIsSeller ? 'seller' : (userIsBuyer ? 'buyer' : 'unknown'));

                    return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Offer ${offer.id} • ${offer.status}'),
                          const SizedBox(height: 4),
                          Text('Perspective: $perspective'),
                          Text('Amount: ${offer.amount}'),
                          if (mutationBlockedReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              mutationBlockedReason,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  autofocus: false,
                                  onPressed: state.mutateStatus == AsyncStatus.loading
                                      ? null
                                      : canMutate
                                      ? () => notifier.counter(
                                            offerId: offer.id,
                                            amount: offer.amount + 50,
                                          )
                                      : () => _showBlockedActionMessage(
                                            context,
                                          mutationBlockedReason,
                                          ),
                                  child: const Text('Counter +50'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  autofocus: false,
                                  onPressed: state.mutateStatus == AsyncStatus.loading
                                      ? null
                                      : canMutate
                                      ? () => notifier.accept(offerId: offer.id)
                                      : () => _showBlockedActionMessage(
                                            context,
                                          mutationBlockedReason,
                                          ),
                                  child: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  autofocus: false,
                                  onPressed: state.mutateStatus == AsyncStatus.loading
                                      ? null
                                      : canMutate
                                      ? () => notifier.reject(offerId: offer.id)
                                      : () => _showBlockedActionMessage(
                                            context,
                                          mutationBlockedReason,
                                          ),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
