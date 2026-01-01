import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';

class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for user's items
  final List<Map<String, dynamic>> _myLostItems = [
    {
      'title': 'iPhone 14 Pro',
      'location': 'Library, Block A',
      'time': '2h ago',
      'category': 'Electronics',
      'status': 'active', // active, claimed, resolved
    },
    {
      'title': 'Car Keys',
      'location': 'Parking Lot',
      'time': '5h ago',
      'category': 'Keys',
      'status': 'active',
    },
    {
      'title': 'Apple Watch',
      'location': 'Gym',
      'time': '1d ago',
      'category': 'Accessories',
      'status': 'resolved',
    },
  ];

  final List<Map<String, dynamic>> _myFoundItems = [
    {
      'title': 'Blue Backpack',
      'location': 'Cafeteria',
      'time': '3h ago',
      'category': 'Bags',
      'status': 'active',
    },
    {
      'title': 'Student ID Card',
      'location': 'Block C, Room 201',
      'time': '1d ago',
      'category': 'Documents',
      'status': 'claimed',
    },
    {
      'title': 'Wallet',
      'location': 'Block B, Ground Floor',
      'time': '2d ago',
      'category': 'Personal',
      'status': 'resolved',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: context.backgroundColor // Using theme default,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Items',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track your reports',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.softShadow,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppColors.primaryGradient,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text('My Lost'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_myLostItems.length}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text('My Found'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_myFoundItems.length}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My Lost Items
                  _buildItemsList(_myLostItems, true),
                  // My Found Items
                  _buildItemsList(_myFoundItems, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items, bool isLost) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLost ? Icons.search_off_rounded : Icons.check_circle_rounded,
              size: 64,
              color: AppColors.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              isLost ? 'No lost items reported' : 'No found items reported',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MyItemCard(
            title: item['title'],
            location: item['location'],
            time: item['time'],
            category: item['category'],
            status: item['status'],
            isLost: isLost,
            onTap: () {
              // Navigate to item detail
            },
            onEdit: () {
              // Edit item
            },
            onDelete: () {
              // Delete item
              _showDeleteDialog(context, item['title']);
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String itemTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "$itemTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete item
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyItemCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String category;
  final String status;
  final bool isLost;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MyItemCard({
    required this.title,
    required this.location,
    required this.time,
    required this.category,
    required this.status,
    required this.isLost,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_rounded;
      case 'Personal':
        return Icons.person_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'Documents':
        return Icons.description_rounded;
      case 'Keys':
        return Icons.key_rounded;
      case 'Bags':
        return Icons.backpack_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return isLost ? AppColors.lostColor : AppColors.foundColor;
      case 'claimed':
        return AppColors.warning;
      case 'resolved':
        return AppColors.claimedColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'claimed':
        return 'Claimed';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = status == 'resolved';

    return Opacity(
      opacity: isResolved ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Item Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: isResolved
                              ? null
                              : (isLost
                                  ? AppColors.lostGradient
                                  : AppColors.foundGradient),
                          color: isResolved ? AppColors.claimedColor : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusText(status),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isResolved) ...[
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
