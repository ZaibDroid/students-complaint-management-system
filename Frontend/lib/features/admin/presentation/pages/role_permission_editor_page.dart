import 'package:flutter/material.dart';
import '../widgets/role_identity_card.dart';
import '../widgets/permission_card.dart';
import '../widgets/permission_toggle_row.dart';

class RolePermissionEditorPage extends StatefulWidget {
  const RolePermissionEditorPage({super.key});

  @override
  State<RolePermissionEditorPage> createState() => _RolePermissionEditorPageState();
}

class _RolePermissionEditorPageState extends State<RolePermissionEditorPage> {
  // Complaint toggles
  bool _complaintView = true;
  bool _complaintForward = true;
  bool _complaintResolve = false;
  bool _complaintArchive = false;
  
  // Notice board toggles
  bool _noticeCreate = true;
  bool _noticeEdit = true;
  bool _noticeDelete = false;
  
  // Staff toggles
  bool _staffView = true;
  bool _staffManage = false;
  
  // Analytics toggles
  bool _analyticsView = true;
  bool _analyticsExport = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Edit Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: const Text('ADMIN VIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const RoleIdentityCard(
            roleName: 'Batch Adviser',
            description: 'Responsible for overseeing student welfare, initial complaint triage, and monitoring academic progress within a specific batch. Access is primarily focused on operational management and reporting.',
          ),
          const SizedBox(height: 24),
          
          PermissionCard(
            title: 'Complaints',
            icon: Icons.gavel,
            color: const Color(0xFF6366F1),
            items: [
              PermissionToggleRow(title: 'View', subtitle: 'Access to view complaint details and status.', value: _complaintView, onChanged: (v) => setState(() => _complaintView = v)),
              PermissionToggleRow(title: 'Forward', subtitle: 'Escalate complaints to higher authorities.', value: _complaintForward, onChanged: (v) => setState(() => _complaintForward = v)),
              PermissionToggleRow(title: 'Resolve', subtitle: 'Mark complaints as completed/resolved.', value: _complaintResolve, onChanged: (v) => setState(() => _complaintResolve = v)),
              PermissionToggleRow(title: 'Archive', subtitle: 'Remove resolved issues from active list.', value: _complaintArchive, onChanged: (v) => setState(() => _complaintArchive = v)),
            ],
          ),
          
          const SizedBox(height: 16),
          PermissionCard(
            title: 'Notice Board',
            icon: Icons.campaign,
            color: const Color(0xFFF59E0B),
            items: [
              PermissionToggleRow(title: 'Create', subtitle: 'Post new official departmental notices.', value: _noticeCreate, onChanged: (v) => setState(() => _noticeCreate = v)),
              PermissionToggleRow(title: 'Edit', subtitle: 'Modify existing notices for your batch.', value: _noticeEdit, onChanged: (v) => setState(() => _noticeEdit = v)),
              PermissionToggleRow(title: 'Delete', subtitle: 'Permenantly remove obsolete notices.', value: _noticeDelete, onChanged: (v) => setState(() => _noticeDelete = v)),
            ],
          ),
          
          const SizedBox(height: 16),
          PermissionCard(
            title: 'Staff Management',
            icon: Icons.group,
            color: const Color(0xFF10B981),
            items: [
              PermissionToggleRow(title: 'View Directory', subtitle: 'Search and view other faculty members.', value: _staffView, onChanged: (v) => setState(() => _staffView = v)),
              PermissionToggleRow(title: 'Manage Profiles', subtitle: 'Update contact info and department tags.', value: _staffManage, onChanged: (v) => setState(() => _staffManage = v)),
            ],
          ),
          
          const SizedBox(height: 16),
          PermissionCard(
            title: 'Analytics',
            icon: Icons.assessment,
            color: theme.primaryColor,
            items: [
              PermissionToggleRow(title: 'View Reports', subtitle: 'Access dashboards for batch performance.', value: _analyticsView, onChanged: (v) => setState(() => _analyticsView = v)),
              PermissionToggleRow(title: 'Export Data', subtitle: 'Download CSV/PDF reports for offline use.', value: _analyticsExport, onChanged: (v) => setState(() => _analyticsExport = v)),
            ],
          ),
          
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Discard Changes', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
