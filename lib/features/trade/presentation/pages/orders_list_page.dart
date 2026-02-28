import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/presentation/pages/order_timeline_page.dart';
import 'package:neobazaar/features/trade/presentation/view_model/order_notifier.dart';

class OrdersListPage extends ConsumerStatefulWidget {
  const OrdersListPage({super.key});

  @override
  ConsumerState<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends ConsumerState<OrdersListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderNotifierProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: state.status == AsyncStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (state.orders.isEmpty) const Text('No orders found.'),
                ...state.orders.map(
                  (order) => Card(
                    child: Semantics(
                      button: true,
                      label: 'Open order ${order.id} timeline',
                      hint: 'Double tap to view order details and timeline',
                      child: ListTile(
                        title: Text('Order ${order.id}'),
                        subtitle: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Status:'),
                            _StatusChip(status: order.status),
                          ],
                        ),
                        onTap: () {
                          AppRoutes.push(
                            context,
                            OrderTimelinePage(orderId: order.id),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'processing':
        color = Colors.deepPurple;
        break;
      case 'shipped':
        color = Colors.indigo;
        break;
      case 'out_for_delivery':
        color = Colors.teal;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.greenAccent.shade700;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'returned':
        color = Colors.brown;
        break;
      case 'refunded':
        color = Colors.cyan;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.18),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
    );
  }
}
