import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InstructorDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instructor Dashboard"),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course & Student Summary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard('Courses', '5'),
                  _buildSummaryCard('Students', '120'),
                  _buildSummaryCard('Ratings', '4.7'),
                ],
              ),
              SizedBox(height: 20),
        
              // Graph Section for Course Completion Rate
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course Completion Rate', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Container(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(toY: 75, color: Colors.blue)
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(toY: 85, color: Colors.blue)
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(toY: 90, color: Colors.blue)
                            ]),
                            BarChartGroupData(x: 3, barRods: [
                              BarChartRodData(toY: 60, color: Colors.blue)
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
        
              // Recent Activity Section
              Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildRecentActivityTile('New student enrolled in "Flutter Basics"'),
              _buildRecentActivityTile('Course "Advanced Python" feedback received'),
              _buildRecentActivityTile('New review received for "React Native" course'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget to build summary cards
  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Helper Widget to build recent activity tile
  Widget _buildRecentActivityTile(String activity) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(activity),
      leading: Icon(Icons.notifications, color: Colors.blue),
    );
  }
}
