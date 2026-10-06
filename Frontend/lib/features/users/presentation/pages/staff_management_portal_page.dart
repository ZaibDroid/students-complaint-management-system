import 'package:flutter/material.dart';

class StaffManagementPortalPage extends StatefulWidget {
  const StaffManagementPortalPage({super.key});

  @override
  State<StaffManagementPortalPage> createState() => _StaffManagementPortalPageState();
}

class _StaffManagementPortalPageState extends State<StaffManagementPortalPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _staffMembers = [
    {
      'id': 'DCMS-7201', 'name': 'Dr. Julian Vance', 'role': 'Chairman', 'location': '2021 Fall - Admin Suite',
      'icon1': Icons.workspace_premium, 'icon2': Icons.calendar_today, 'color': const Color(0xFF10B981)
    },
    {
      'id': 'DCMS-8842', 'name': 'Elena Rodriguez', 'role': 'Batch Adviser', 'location': '2021 Fall - CS Section A',
      'icon1': Icons.verified_user, 'icon2': Icons.groups, 'color': const Color(0xFF6366F1)
    },
    {
      'id': 'DCMS-1044', 'name': 'Marcus Chen', 'role': 'Coordinator', 'location': '2022 Spring - IT Dept',
      'icon1': Icons.hub, 'icon2': Icons.home_work, 'color': const Color(0xFFF59E0B)
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Staff Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: const Text('A', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search staff by name or ID...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Advisers', 'Coordinators', 'Office Staff'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _staffMembers.length,
              itemBuilder: (context, index) {
                final staff = _staffMembers[index];
                return _buildStaffCard(staff, theme);
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: staff['color'], width: 4), top: BorderSide(color: Colors.grey.shade200), bottom: BorderSide(color: Colors.grey.shade200), right: BorderSide(color: Colors.grey.shade200)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person, size: 32, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff['id'], style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(staff['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(staff['icon1'], size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(staff['role'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(staff['icon2'], size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(staff['location'], style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF172548).withValues(alpha: 0.1),
                foregroundColor: const Color(0xFF172548),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Manage Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
