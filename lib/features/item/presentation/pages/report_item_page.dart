import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  bool _isLostItem = true;
  String _selectedCategory = 'Electronics';
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electronics', 'icon': Icons.devices_rounded},
    {'name': 'Personal', 'icon': Icons.person_rounded},
    {'name': 'Accessories', 'icon': Icons.watch_rounded},
    {'name': 'Documents', 'icon': Icons.description_rounded},
    {'name': 'Keys', 'icon': Icons.key_rounded},
    {'name': 'Bags', 'icon': Icons.backpack_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Report Item',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lost/Found Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLostItem = true;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: _isLostItem
                                        ? AppColors.lostGradient
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 20,
                                        color: _isLostItem
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'I Lost Something',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isLostItem
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isLostItem = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: !_isLostItem
                                        ? AppColors.foundGradient
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 20,
                                        color: !_isLostItem
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'I Found Something',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: !_isLostItem
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Photo/Video Upload Section
                      Text(
                        'Add Photos / Videos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Add Photo Button
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement image picker
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: _isLostItem
                                          ? AppColors.lostGradient
                                          : AppColors.foundGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.add_a_photo_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Photo / Video',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Item Title
                      Text(
                        'Item Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., iPhone 14 Pro, Blue Wallet',
                            hintStyle: TextStyle(color: AppColors.textTertiary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter item title';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category Selection
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['name'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? (_isLostItem
                                        ? AppColors.lostGradient
                                        : AppColors.foundGradient)
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppColors.softShadow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Location
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: _isLostItem
                                ? 'Where did you lose it?'
                                : 'Where did you find it?',
                            hintStyle:
                                TextStyle(color: AppColors.textTertiary),
                            prefixIcon: Icon(
                              Icons.location_on_rounded,
                              color: context.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                'Provide additional details about the item...',
                            hintStyle: TextStyle(color: AppColors.textTertiary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Submit the form
                            SnackbarUtils.showSuccess(
                              context,
                              _isLostItem
                                  ? 'Lost item reported successfully!'
                                  : 'Found item reported successfully!',
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: _isLostItem
                                ? AppColors.lostGradient
                                : AppColors.foundGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isLostItem
                                    ? Icons.campaign_rounded
                                    : Icons.add_task_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isLostItem ? 'Report Lost Item' : 'Report Found Item',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
