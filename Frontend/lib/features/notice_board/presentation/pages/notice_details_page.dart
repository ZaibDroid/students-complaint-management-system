import 'package:flutter/material.dart';
import '../../data/models/notice_model.dart';
import 'dart:convert';

class NoticeDetailsPage extends StatelessWidget {
  final NoticeModel? notice;

  const NoticeDetailsPage({super.key, this.notice});

  @override
  Widget build(BuildContext context) {
    if (notice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Notice data could not be loaded. Please return to the previous screen.')),
      );
    }
    
    final theme = Theme.of(context);
    final isUrgent = notice!.tag == 'Urgent';
    final date = notice!.createdAt;
    final dateStr = '${date.day.toString().padLeft(2, '0')} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month-1]} ${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notice Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.error, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text('URGENT', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Text(notice!.tag.toUpperCase(), style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            notice!.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text('Published on $dateStr', style: const TextStyle(color: Colors.black54)),
              const SizedBox(width: 16),
              const Icon(Icons.schedule, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text(timeStr, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFDAE2FF), borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.account_balance, color: Color(0xFF0B1A3C)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notice!.senderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Department of Computer Science', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          SelectableText(
            notice!.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          
          if (notice!.attachments != null && notice!.attachments!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.primaryColor)),
            const SizedBox(height: 16),
            ...notice!.attachments!.map((attach) {
              final b64 = attach.split(',').last;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(base64Decode(b64), fit: BoxFit.cover),
                ),
              );
            }),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
