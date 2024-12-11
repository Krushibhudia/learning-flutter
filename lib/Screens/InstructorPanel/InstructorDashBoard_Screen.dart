import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CreateCourse_Screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/ManageCourse.dart';
import 'InstructorProfile_screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User's course data
  List<Map<String, dynamic>> _courses = [];
  int _totalStudents = 0;
  double _averageRating = 0.0;
  int _totalCourses = 0;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _fetchInstructorData();
  }

  Future<void> _fetchInstructorData() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('No user is logged in');
        return;
      }

      QuerySnapshot courseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      // Process the courses data
      setState(() {
        _courses = courseSnapshot.docs
            .map((doc) {
          // Add the course id to the course data
          Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
          courseData['id'] = doc.id; // Add the document id
          return courseData;
        })
            .toList();

        _totalCourses = _courses.length;
        _totalStudents = _courses.fold(0, (sum, course) => course['studentsCount'] ?? 0);
        _averageRating = _courses.isNotEmpty
            ? _courses.fold(0.0, (sum, course) => sum + (course['rating'] ?? 0.0)) / _courses.length
            : 0.0;
      });
    } catch (e) {
      print("Error fetching instructor data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [

          IconButton(icon: Icon(Icons.account_circle), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>InstructorProfilePage()));
          }),
        ],
      ),
        drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          'Instructor Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      // Course Management - ExpansionTile
      ExpansionTile(
        title: Text('Course Management'),
        children: [
          ListTile(
            title: Text('Create Course'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateCourseScreen()));
            },
          ),
          ListTile(
            title: Text('Manage Courses'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ManageCourseScreen()));
            },
          ),
          ListTile(
            title: Text('Course Reports'),
            onTap: () {
              // Navigate to Course Reports screen
            },
          ),
        ],
      ),
      ListTile(
        title: Text('Instructor Profile'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InstructorProfilePage()),
          );
        },
      ),
      ListTile(
        title: Text('Settings'),
        onTap: () {
          // Navigate to Settings screen
        },
      ),
    ],
  ),
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
                  _buildSummaryCard('Courses', _totalCourses.toString(), color: Colors.red),
                  _buildSummaryCard('Students', _totalStudents.toString(), color: Colors.orange),
                  _buildSummaryCard('Ratings', _averageRating.toStringAsFixed(1), color: Colors.indigoAccent),
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
    final baseColor = color ?? Colors.blueAccent;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 115, // Adjusted width for better spacing
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              baseColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.4), // Shadow matches the gradient
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
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
