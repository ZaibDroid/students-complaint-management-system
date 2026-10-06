import 'package:flutter/material.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('General Configuration'),
          _buildSettingsGroup([
            _buildSettingsItem(Icons.corporate_fare, 'Department Identity', 'Name, logo, and brand colors', theme),
            _buildSettingsItem(Icons.calendar_today, 'Academic Calendar', 'Semester dates and holidays', theme),
          ]),
          
          _buildSectionTitle('Workflow & Logic'),
          _buildSettingsGroup([
            _buildSettingsItem(Icons.category, 'Complaint Categories', 'Define academic vs admin issues', theme),
            _buildSettingsItem(Icons.timer, 'SLA & Deadlines', 'Resolution time limits (48h-7d)', theme),
            _buildSettingsItem(Icons.trending_up, 'Escalation Rules', 'Auto-transfer to Dean/Board', theme),
          ]),
          
          _buildSectionTitle('User & Security'),
          _buildSettingsGroup([
            _buildSettingsItem(Icons.admin_panel_settings, 'Role Permissions', 'Deans, Chairmen, and Staff', theme),
            _buildSettingsItem(Icons.person_add, 'Staff Management', 'Assigning roles to faculty', theme),
            _buildSettingsItem(Icons.security, 'Login Security', '2FA and session timeouts', theme),
          ]),
          
          _buildSectionTitle('System Utilities'),
          _buildSettingsGroup([
            _buildSettingsItem(Icons.mail, 'Notification Templates', 'Email and SMS triggers', theme),
            _buildSettingsItem(Icons.cloud_download, 'Backup & Data Export', 'Automated daily snapshots', theme),
            _buildSettingsItem(Icons.history_edu, 'Audit Logs', 'Track all administrative actions', theme),
          ]),
          
          const SizedBox(height: 16),
          const Text('Advanced Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.red)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.settings_backup_restore, color: Colors.red),
              ),
              title: const Text('System Reset', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text('Clear all data and configurations', style: TextStyle(fontSize: 13, color: Colors.black54)),
              onTap: () {},
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black54),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.expand((item) => [item, const Divider(height: 1)]).toList()..removeLast(),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: theme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
