import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';

class ProfileAcademicCard extends StatelessWidget {
  final User user;

  const ProfileAcademicCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isStudent = user.role == 'Student';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(isStudent ? Icons.school : Icons.badge, color: theme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  isStudent ? 'Academic Information' : 'Staff Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (isStudent) ...[
            if (user.registrationNumber != null && user.registrationNumber!.isNotEmpty) ...[
              _buildTableRow('Registration No.', user.registrationNumber!),
              const Divider(height: 1),
            ],
            _buildTableRow(
              'Department',
              (user.department != null && user.department!.trim().isNotEmpty)
                  ? user.department!
                  : 'Department of Computer Science',
            ),
            const Divider(height: 1),
            _buildTableRow(
              'Batch',
              (user.batch != null && user.batch!.isNotEmpty) ? user.batch! : 'Not Set',
            ),
            const Divider(height: 1),
            Builder(
              builder: (context) {
                final semVal = (user.year ?? user.semester ?? '').trim();
                final semDisplay = semVal.isNotEmpty
                    ? (semVal.toLowerCase().startsWith('semester') ? semVal : 'Semester $semVal')
                    : 'Not Set';
                return _buildTableRow('Semester', semDisplay);
              },
            ),
            const Divider(height: 1),
            _buildTableRow(
              'Section',
              (user.section != null && user.section!.isNotEmpty) ? user.section! : 'Not Set',
            ),
            const Divider(height: 1),
            _buildTableRow(
              'Batch Adviser',
              (user.adviser != null && user.adviser!.isNotEmpty) ? user.adviser! : 'Not Linked',
            ),
            const Divider(height: 1),
            _buildTableRow(
              'Contact Number',
              (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : 'Not Set',
            ),
          ] else ...[
            _buildTableRow(
              'Department',
              (user.department != null && user.department!.trim().isNotEmpty) ? user.department! : 'N/A',
            ),
            const Divider(height: 1),
            if (user.role == 'Batch Adviser' || user.role == 'Coordinator') ...[
              _buildTableRow(
                user.role == 'Coordinator' ? 'Coordinating Batch' : 'Advising Batch',
                user.batch ?? 'N/A',
              ),
              const Divider(height: 1),
              if (user.role == 'Batch Adviser') ...[
                _buildTableRow('Advising Section', user.section ?? 'N/A'),
                const Divider(height: 1),
              ],
            ],
            _buildTableRow('Contact Number', user.phone ?? 'N/A'),
          ],
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

