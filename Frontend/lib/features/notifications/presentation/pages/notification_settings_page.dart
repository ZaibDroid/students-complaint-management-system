import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _muteAll = false;
  bool _newComplaint = true;
  bool _complaintForwarded = false;
  bool _complaintResolved = true;
  bool _newNotice = true;
  bool _newLogin = true;
  String _digestFreq = 'weekly';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Mute All
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFDAE2FF), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.notifications_off, color: Color(0xFF0B1A3C)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mute All Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Temporarily silence all alerts', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: _muteAll,
                  onChanged: (val) => setState(() => _muteAll = val),
                  activeThumbColor: theme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('COMPLAINT ALERTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildToggleRow('New Complaint Submitted', 'Get notified when a new complaint is filed', _newComplaint, (val) => setState(() => _newComplaint = val)),
                const Divider(height: 1),
                _buildToggleRow('Complaint Forwarded', 'Alert when a case is escalated', _complaintForwarded, (val) => setState(() => _complaintForwarded = val)),
                const Divider(height: 1),
                _buildToggleRow('Complaint Resolved', 'Final confirmation when a case is closed', _complaintResolved, (val) => setState(() => _complaintResolved = val)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('DEPARTMENTAL NOTICES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: _buildToggleRow('New Notice Posted', 'Alerts for broad announcements', _newNotice, (val) => setState(() => _newNotice = val)),
          ),
          
          const SizedBox(height: 24),
          const Text('SECURITY & SYSTEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: _buildToggleRow('New Login Detected', 'Security alert for unrecognized device access', _newLogin, (val) => setState(() => _newLogin = val)),
          ),
          
          const SizedBox(height: 24),
          const Text('CHANNEL PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stay_current_portrait, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          const Text('Push Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Instant updates', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ENABLED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.primaryColor, width: 2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.mail, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          const Text('Email Digest', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _digestFreq,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily Recap')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly Summary')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly Report')),
                        ],
                        onChanged: (val) => setState(() => _digestFreq = val!),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
