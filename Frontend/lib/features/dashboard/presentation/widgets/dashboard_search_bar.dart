import 'package:flutter/material.dart';

class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search your complaints by ID or title...',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
