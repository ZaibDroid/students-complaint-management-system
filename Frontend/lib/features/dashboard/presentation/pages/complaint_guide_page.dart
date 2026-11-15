import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComplaintGuidePage extends StatelessWidget {
  const ComplaintGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text(
          'Complaint Filing Guide',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Fill the Complaint Form',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Follow this simple step-by-step guide to make sure your complaint is addressed quickly and reaches the right office.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section 1: Form Fields Breakdown
            _buildSectionHeader('Part 1: The 4 Form Fields', Icons.edit_document, Colors.blue),
            const SizedBox(height: 14),

            _buildFieldCard(
              number: '1',
              fieldName: 'Category',
              badgeText: 'Required',
              badgeColor: Colors.blue,
              summary: 'Choose the area where you are facing an issue:',
              bulletPoints: [
                'Academic Affairs: Issues with lectures, grades, exam schedules, teacher problems, course registration, or attendance discrepancies.',
                'Facility & Infrastructure: Broken benches, lights, fans, air conditioning, lab equipment, washrooms, clean water, or building repairs.',
                'IT & Network Support: Campus Wi-Fi not connecting, student portal/LMS login issues, or computer lab hardware/software problems.',
                'Finance & Fees: Semester fee vouchers/challan, scholarship queries, dues clearance, fee refunds, or payment receipts.',
              ],
            ),
            const SizedBox(height: 14),

            _buildFieldCard(
              number: '2',
              fieldName: 'Subject',
              badgeText: 'Required',
              badgeColor: Colors.teal,
              summary: 'A short, one-line summary of your issue.',
              bulletPoints: [
                'Write what the problem is in a few clear words.',
                'Good Example: "Projector not working in Room 102"',
                'Good Example: "Attendance correction for CS-301"',
                'Avoid: One-word titles like "Help" or "Problem".',
              ],
            ),
            const SizedBox(height: 14),

            _buildFieldCard(
              number: '3',
              fieldName: 'Detailed Description',
              badgeText: 'Required',
              badgeColor: Colors.amber.shade800,
              summary: 'Explain your concern clearly so staff can take immediate action:',
              bulletPoints: [
                'What: Describe the exact problem that occurred.',
                'Where: Specify the room number, lab name, or department building.',
                'When: Mention when the issue started.',
                'Request: State what resolution or fix you are requesting.',
              ],
            ),
            const SizedBox(height: 14),

            _buildFieldCard(
              number: '4',
              fieldName: 'Attachment',
              badgeText: 'Optional',
              badgeColor: Colors.purple,
              summary: 'Attach proof to help solve your complaint faster:',
              bulletPoints: [
                'Upload a photo of broken equipment, error screenshot, or application letter.',
                'Supported formats: JPG, PNG, PDF, DOC, DOCX.',
                'Maximum allowed file size: 5 MB.',
              ],
            ),
            const SizedBox(height: 28),

            // Section 2: Lifecycle
            _buildSectionHeader('Part 2: What Happens After You Submit?', Icons.alt_route, Colors.green),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                children: [
                  _ProcessRow(
                    step: '1',
                    title: 'Auto-Routing & Ticket ID',
                    desc: 'Your complaint receives a tracking Ticket ID and is routed automatically to your Batch Adviser.',
                  ),
                  SizedBox(height: 14),
                  _ProcessRow(
                    step: '2',
                    title: 'Staff Review & Action',
                    desc: 'The adviser investigates your request or forwards it directly to the Coordinator or relevant department.',
                  ),
                  SizedBox(height: 14),
                  _ProcessRow(
                    step: '3',
                    title: 'Resolution & Status Update',
                    desc: 'When completed, the status updates to "Resolved" and you can review notes and feedback in real-time.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section 3: Student Rules
            _buildSectionHeader('Helpful Student Guidelines', Icons.lightbulb_outline, Colors.orange),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  _GuidelineRow(
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    text: 'Make sure you have linked an approved Batch Adviser from your profile before submitting complaints.',
                  ),
                  SizedBox(height: 10),
                  _GuidelineRow(
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    text: 'Always write in clear, polite, and respectful language.',
                  ),
                  SizedBox(height: 10),
                  _GuidelineRow(
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    text: 'Do not file multiple complaints for the same problem; track the existing ticket on the Complaints page.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/submit_complaint');
            },
            icon: const Icon(Icons.edit_document),
            label: const Text(
              'Start Filing a Complaint',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String number,
    required String fieldName,
    required String badgeText,
    required Color badgeColor,
    required String summary,
    required List<String> bulletPoints,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: badgeColor.withValues(alpha: 0.15),
                child: Text(
                  number,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fieldName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...bulletPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  final String step;
  final String title;
  final String desc;

  const _ProcessRow({required this.step, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidelineRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _GuidelineRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.35),
          ),
        ),
      ],
    );
  }
}

