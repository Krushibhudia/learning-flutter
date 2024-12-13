import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Custom_Widgets/GradientButton.dart';

class EarningsAndPaymentScreen extends StatelessWidget {
  final List<Map<String, dynamic>> coursesEarnings = [
    {'course': 'Flutter Basics', 'earnings': 150.0},
    {'course': 'Advanced Flutter', 'earnings': 300.0},
    {'course': 'UI/UX Design', 'earnings': 250.0},
    {'course': 'Data Science', 'earnings': 180.0},
  ];

  final List<Map<String, dynamic>> paymentHistory = [
    {'date': '2024-11-01', 'amount': 500.0, 'status': 'Completed'},
    {'date': '2024-11-15', 'amount': 300.0, 'status': 'Pending'},
    {'date': '2024-11-20', 'amount': 450.0, 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate total earnings
    double totalEarnings = coursesEarnings.fold(0.0, (sum, course) => sum + course['earnings']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Withdraw funds logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Section
            Text(
              'Total Earnings: \$${totalEarnings.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Earnings Visualization - Pie Chart
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: coursesEarnings.map((course) {
                    return PieChartSectionData(
                      value: course['earnings'],
                      color: Colors.primaries[coursesEarnings.indexOf(course) % Colors.primaries.length],
                      title: '\$${course['earnings'].toStringAsFixed(0)}',
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Course Earnings Breakdown Table
            Text(
              'Course Earnings Breakdown:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Course', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...coursesEarnings.map((course) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(course['course']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('\$${course['earnings'].toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),

            // Payment History Section
            Text(
              'Payment History:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Expanded widget ensures payment history takes remaining space
            Container(
              height: 250, // Set a fixed height or use the Expanded widget
              child: ListView.builder(
                itemCount: paymentHistory.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    child: ListTile(
                      title: Text(paymentHistory[index]['date']),
                      subtitle: Text('Amount: \$${paymentHistory[index]['amount'].toStringAsFixed(2)}'),
                      trailing: Text(
                        paymentHistory[index]['status'],
                        style: TextStyle(
                          color: paymentHistory[index]['status'] == 'Completed' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Withdraw Funds Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GradientButton(
                buttonText: 'Withdraw Funds',
                onPressed: () {
                  // Handle withdrawal logic
                },
                gradientColors: [Colors.blueAccent, Colors.lightBlue], label: '',child: Text(""), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
