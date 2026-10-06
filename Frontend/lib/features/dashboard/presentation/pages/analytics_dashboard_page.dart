import 'package:flutter/material.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(), // We reuse this from earlier
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Metrics
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172548),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Complaints', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        SizedBox(height: 8),
                        Text('1,284', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.trending_down, color: Colors.greenAccent, size: 16),
                            SizedBox(width: 4),
                            Text('12.5% from last month', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Avg. Resolution', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('3.2 Days', style: TextStyle(color: theme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('Fast performance', style: TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Satisfaction', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('94.8%', style: TextStyle(color: theme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.948,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Category Breakdown (Mock Bar Chart)
            Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Academic', 0.85, theme.primaryColor),
                  _buildBar('Maint.', 0.45, theme.primaryColor),
                  _buildBar('Security', 0.25, theme.primaryColor),
                  _buildBar('Finan.', 0.60, theme.primaryColor),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Monthly Trends
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                  child: const Text('2024 YTD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.show_chart, size: 80, color: theme.primaryColor.withValues(alpha: 0.2)),
                  const Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jan', style: TextStyle(fontSize: 10, color: Colors.black54)),
                        Text('Mar', style: TextStyle(fontSize: 10, color: Colors.black54)),
                        Text('May', style: TextStyle(fontSize: 10, color: Colors.black54)),
                        Text('Jul', style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Performance by Role
            Text('Performance by Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            const SizedBox(height: 16),
            _buildRoleRow('Batch Advisers', 'Avg. 1.8 days', '98%', true),
            const SizedBox(height: 8),
            _buildRoleRow('Coordinators', 'Avg. 4.2 days', '84%', null),
            const SizedBox(height: 8),
            _buildRoleRow('Dept. Heads', 'Avg. 5.1 days', '76%', false),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double fill, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: 32,
                  height: constraints.maxHeight * fill,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildRoleRow(String role, String avg, String pct, bool? isUp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.black54, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(avg, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (isUp != null) Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: isUp ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text(pct, style: TextStyle(fontWeight: FontWeight.bold, color: isUp == null ? Colors.amber : (isUp ? Colors.green : Colors.red))),
                    ],
                  ),
                  const Text('RESOLVED', style: TextStyle(fontSize: 8, color: Colors.black54, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ],
      ),
    );
  }
}
