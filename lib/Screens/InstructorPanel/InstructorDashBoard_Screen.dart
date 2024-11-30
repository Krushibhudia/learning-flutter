import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterpro/Screens/InstructorPanel/Settings_Screen.dart';
import 'InstructorProfile_screen.dart';

class InstructorDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
          actions: [
      IconButton(icon: Icon(Icons.settings), onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen()));
      }),
    IconButton(icon: Icon(Icons.account_circle), onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>InstructorProfilePage()));
    },
          ),
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

  Widget _buildSummaryCard(String title, String value, {Color? color}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 110,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color ?? Colors.blueAccent, // Default color if not passed
              color?.withOpacity(0.6) ?? Colors.lightBlueAccent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
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
