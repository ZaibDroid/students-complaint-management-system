import 'package:flutter/material.dart';

/// Reusable card component representing a selectable recipient staff member.
class RecipientStaffCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final bool isSelected;
  final bool isAdviserSendBack;
  final bool isOffice;
  final String roleLabel;
  final ValueChanged<String> onSelected;

  const RecipientStaffCard({
    super.key,
    required this.staff,
    required this.isSelected,
    required this.isAdviserSendBack,
    required this.isOffice,
    required this.roleLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffId = staff['id'] as String;
    final staffName = staff['name'] as String;

    return GestureDetector(
      onTap: () => onSelected(staffId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isAdviserSendBack
                  ? Colors.amber.shade50
                  : theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                isAdviserSendBack
                    ? Icons.undo_rounded
                    : (isOffice ? Icons.desk : Icons.person),
                color: isAdviserSendBack ? Colors.amber.shade800 : theme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        staffName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (isAdviserSendBack)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Send Back',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      color: isAdviserSendBack ? Colors.amber.shade800 : theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // ignore: deprecated_member_use
            Radio<String>(
              value: staffId,
              // ignore: deprecated_member_use
              groupValue: isSelected ? staffId : null,
              activeColor: theme.primaryColor,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) onSelected(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
