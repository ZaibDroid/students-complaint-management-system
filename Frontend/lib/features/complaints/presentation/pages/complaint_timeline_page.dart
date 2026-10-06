import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/timeline_node.dart';

class ComplaintTimelinePage extends ConsumerWidget {
  const ComplaintTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Track Complaint',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 18, color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border(left: BorderSide(color: Colors.indigo, width: 4)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '#DC-2945',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: Colors.black54,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
                        ),
                        child: const Text(
                          'FORWARDED',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Library Cooling System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reported: Oct 12, 2023 • General Maintenance',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'COMPLAINT JOURNEY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Timeline
            TimelineNode(
              title: 'Pending Chairman Approval',
              subtitle: 'Waiting for administrative review',
              status: TimelineNodeStatus.future,
              icon: Icons.hourglass_empty,
            ),
            TimelineNode(
              title: 'Forwarded to Coordinator',
              subtitle: 'TODAY, 10:45 AM',
              status: TimelineNodeStatus.active,
              icon: Icons.forward,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                      child: Icon(Icons.person, size: 14, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prof. Sarah Jenkins',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TimelineNode(
              title: 'Reviewed by Batch Adviser',
              subtitle: 'OCT 13, 2:15 PM',
              status: TimelineNodeStatus.completed,
              icon: Icons.check,
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                    children: [
                      TextSpan(
                        text: 'Remarks: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                      const TextSpan(
                        text: 'Issue verified. Cooling system in Sector B is non-functional. Requesting escalation to department coordinator for fund allocation.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const TimelineNode(
              title: 'Complaint Submitted',
              subtitle: 'OCT 12, 9:00 AM',
              status: TimelineNodeStatus.completed,
              icon: Icons.check,
              isLast: true,
              content: Text(
                'Ticket generated successfully by user.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Attachments
            const Text(
              'ATTACHED MEDIA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                    ),
                    child: Container( // Dashed border placeholder
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('ROOM_LOG.PDF', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support for this Ticket'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
