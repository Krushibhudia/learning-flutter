import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              // TODO: Add filter logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Performance Section
            Text(
              'Course Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            CoursePerformanceGraph(),
            SizedBox(height: 16),
            CoursePerformanceList(),

            // Earnings Reports Section
            SizedBox(height: 16),
            Text(
              'Earnings Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            EarningsPieChart(),
            SizedBox(height: 16),
            EarningsSummaryCard(),

            // Student Activity Section
            SizedBox(height: 16),
            Text(
              'Student Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            StudentEngagementBarChart(),
            SizedBox(height: 16),
            StudentActivitySummary(),
          ],
        ),
      ),
    );
  }
}

// Course Performance Graph
class CoursePerformanceGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 50),
                FlSpot(1, 70),
                FlSpot(2, 100),
                FlSpot(3, 85),
                FlSpot(4, 95),
              ],
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// Course Performance List
class CoursePerformanceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CoursePerformanceCard(courseName: 'Flutter Basics', completionRate: 85),
        CoursePerformanceCard(courseName: 'Advanced Dart', completionRate: 92),
        CoursePerformanceCard(courseName: 'UI Design Patterns', completionRate: 78),
      ],
    );
  }
}

class CoursePerformanceCard extends StatelessWidget {
  final String courseName;
  final double completionRate;

  CoursePerformanceCard({required this.courseName, required this.completionRate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(courseName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completion Rate: ${completionRate.toInt()}%'),
            SizedBox(height: 4),
            LinearProgressIndicator(value: completionRate / 100),
          ],
        ),
        trailing: Icon(Icons.bar_chart, color: Colors.blue),
      ),
    );
  }
}

// Earnings Pie Chart
class EarningsPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, title: 'Course A', color: Colors.blue),
            PieChartSectionData(value: 30, title: 'Course B', color: Colors.orange),
            PieChartSectionData(value: 30, title: 'Course C', color: Colors.green),
          ],
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}

// Earnings Summary Card
class EarningsSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Earnings: \$10,000', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('This Month: \$2,000', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// Student Engagement Bar Chart
class StudentEngagementBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.blue)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.blue)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.blue)]),
          ],
        ),
      ),
    );
  }
}

// Student Activity Summary
class StudentActivitySummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Student Engagement Summary'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logins this week: 120'),
            Text('Lessons completed: 250'),
          ],
        ),
        trailing: Icon(Icons.group, color: Colors.blue),
      ),
    );
  }
}
