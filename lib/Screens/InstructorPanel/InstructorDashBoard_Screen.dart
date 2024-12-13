import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CourseAnalytics.dart';
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
  int _totalCourses = 0;

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

    // Fetch courses for the logged-in instructor
    QuerySnapshot courseSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .get();

    if (courseSnapshot.docs.isEmpty) {
      print('No courses found');
      return;
    }

    // Fetch all courses and their student count
    List<Map<String, dynamic>> fetchedCourses = [];
    int totalStudentsCount = 0;

    // Iterate through all course documents
    for (var doc in courseSnapshot.docs) {
      Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
      courseData['id'] = doc.id;

      // Count the number of students in the enrolledStudents subcollection
      QuerySnapshot studentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(doc.id)
          .collection('enrolledStudents')
          .get();

      int studentCount = studentsSnapshot.size; // The number of documents in this subcollection

      // Print to debug
      print("Course ID: ${doc.id}, Enrolled Students: $studentCount");

      // Update the total students count
      totalStudentsCount += studentCount;

      // Add student count to course data
      courseData['studentCount'] = studentCount;

      // Add course data to the list
      fetchedCourses.add(courseData);
    }

    // Update state with fetched courses and student count
    setState(() {
      _courses = fetchedCourses;
      _totalCourses = _courses.length;
      _totalStudents = totalStudentsCount;
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
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InstructorProfilePage()));
            },
          ),
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
            ListTile(
              title: Text('Create Course'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateCourseScreen()));
              },
            ),
            ListTile(
              title: Text('Manage Courses'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManageCourseScreen()));
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
                ],
              ),
              SizedBox(height: 20),
              // Course Details Section
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return _buildCourseDetails(_courses[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {Color? color}) {
    final baseColor = color ?? Colors.blueAccent;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 175,
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
              color: baseColor.withOpacity(0.4),
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

Widget _buildCourseDetails(Map<String, dynamic> course) {
  int studentCount = course['studentCount'] ?? 0;  // Get student count from course data

  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      title: Text(course['title'] ?? 'Untitled Course'),
      subtitle: Text('$studentCount Students'),  // Display the student count
    ),
  );
}



}
