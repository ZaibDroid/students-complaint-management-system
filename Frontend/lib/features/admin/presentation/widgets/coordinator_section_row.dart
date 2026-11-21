import 'package:flutter/material.dart';

/// Reusable table row representing a single section and its assigned Batch Adviser.
class CoordinatorSectionRow extends StatelessWidget {
  final String section;
  final bool isAssigned;
  final String adviserName;
  final String? adviserEmail;
  final bool isEvenRow;
  final VoidCallback onAssignOrChange;
  final VoidCallback onRemoveSection;

  const CoordinatorSectionRow({
    super.key,
    required this.section,
    required this.isAssigned,
    required this.adviserName,
    this.adviserEmail,
    required this.isEvenRow,
    required this.onAssignOrChange,
    required this.onRemoveSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isEvenRow ? Colors.white : const Color(0xFFFBFBFD),
      child: Row(
        children: [
          // Section Badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF172548).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF172548).withValues(alpha: 0.15)),
            ),
            alignment: Alignment.center,
            child: Text(
              section,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172548),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Adviser Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAssigned ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 15,
                      color: isAssigned ? Colors.green.shade600 : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        adviserName,
                        style: TextStyle(
                          fontWeight: isAssigned ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                          color: isAssigned ? const Color(0xFF0F172A) : Colors.orange.shade800,
                          fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isAssigned && adviserEmail != null && adviserEmail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 21, top: 2),
                    child: Text(
                      adviserEmail!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Button: Assign / Change
          isAssigned
              ? OutlinedButton.icon(
                  onPressed: onAssignOrChange,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF172548),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              : IconButton(
                  onPressed: onAssignOrChange,
                  icon: const Icon(Icons.person_add_alt_1, size: 16),
                  tooltip: 'Assign',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF172548),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

          // Remove Section Button
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
            tooltip: 'Remove Section $section',
            onPressed: onRemoveSection,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

