import 'package:flutter/material.dart';

class RoleIdentityCard extends StatelessWidget {
  final String roleName;
  final String description;

  const RoleIdentityCard({
    super.key,
    required this.roleName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF172548),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Color(0xFF7F8DB6), size: 16),
              SizedBox(width: 8),
              Text(
                'SYSTEM ROLE',
                style: TextStyle(
                  color: Color(0xFF7F8DB6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            roleName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF7F8DB6), height: 1.5),
          ),
        ],
      ),
    );
  }
}
