import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/trade/presentation/view_model/order_notifier.dart';

class OrderTimelinePage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTimelinePage({super.key, required this.orderId});

  @override
  ConsumerState<OrderTimelinePage> createState() => _OrderTimelinePageState();
}

class _OrderTimelinePageState extends ConsumerState<OrderTimelinePage> {
  final TextEditingController _noteController = TextEditingController();
  String _selectedStatus = 'in_transit';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderNotifierProvider.notifier).fetchTimeline(widget.orderId);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);
    final notifier = ref.read(orderNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Timeline ${widget.orderId}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (state.timeline.isEmpty) const Text('No timeline events yet.'),
          ...state.timeline.map(
            (event) => ListTile(
              leading: const Icon(Icons.timeline),
              title: Text(event.type),
              subtitle: Text(event.message ?? '-'),
            ),
          ),
          const Divider(height: 24),
          const Text('Append Timeline (Seller Action)'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'created', child: Text('created')),
              DropdownMenuItem(value: 'paid', child: Text('paid')),
              DropdownMenuItem(value: 'in_transit', child: Text('in_transit')),
              DropdownMenuItem(value: 'delivered', child: Text('delivered')),
              DropdownMenuItem(value: 'completed', child: Text('completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('cancelled')),
              DropdownMenuItem(value: 'disputed', child: Text('disputed')),
            ],
            onChanged: (value) {
              if (value == null || value.isEmpty) {
                return;
              }
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              notifier.appendTimeline(
                orderId: widget.orderId,
                status: _selectedStatus,
                note: _noteController.text.trim(),
              );
            },
            child: const Text('Append Timeline Event'),
          ),
        ],
      ),
    );
  }
}
