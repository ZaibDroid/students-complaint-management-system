import 'package:flutter/material.dart';
import '../../shared/enums/complaint_status.dart';
import '../../shared/enums/priority_level.dart';
import '../constants/app_colors.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final ComplaintStatus? initialStatus;
  final PriorityLevel? initialPriority;
  final String? initialCategory;
  final ValueChanged<FilterCriteria> onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    this.initialStatus,
    this.initialPriority,
    this.initialCategory,
    required this.onApply,
    required this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    ComplaintStatus? initialStatus,
    PriorityLevel? initialPriority,
    String? initialCategory,
    required ValueChanged<FilterCriteria> onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FilterBottomSheet(
        initialStatus: initialStatus,
        initialPriority: initialPriority,
        initialCategory: initialCategory,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class FilterCriteria {
  final ComplaintStatus? status;
  final PriorityLevel? priority;
  final String? category;

  const FilterCriteria({this.status, this.priority, this.category});
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  ComplaintStatus? _selectedStatus;
  PriorityLevel? _selectedPriority;
  String? _selectedCategory;

  final List<String> _categories = [
    'All Categories',
    'Academic Issues',
    'Faculty / Teaching',
    'Lab & Equipment',
    'Examination & Results',
    'Hostel / Transport',
    'Fee & Scholarships',
    'Administrative / Office',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedPriority = widget.initialPriority;
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Complaints',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedPriority = null;
                      _selectedCategory = null;
                    });
                    widget.onReset();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.statusRejected)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter
            const Text(
              'Workflow Status',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ComplaintStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status.displayName),
                  selected: isSelected,
                  selectedColor: AppColors.primarySurface,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == (cat == 'All Categories' ? null : cat);
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primarySurface,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? (cat == 'All Categories' ? null : cat) : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Priority Filter
            const Text(
              'Priority Level',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PriorityLevel.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return ChoiceChip(
                  label: Text(priority.displayName),
                  selected: isSelected,
                  selectedColor: priority.color.withValues(alpha: 0.15),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? priority.color : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected ? priority.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    height: 46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Apply Filters',
                    height: 46,
                    onPressed: () {
                      widget.onApply(
                        FilterCriteria(
                          status: _selectedStatus,
                          priority: _selectedPriority,
                          category: _selectedCategory,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
