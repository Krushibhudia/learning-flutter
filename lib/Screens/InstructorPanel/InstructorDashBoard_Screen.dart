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

      QuerySnapshot courseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .get();

      List<Map<String, dynamic>> fetchedCourses = [];

      for (var doc in courseSnapshot.docs) {
        Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
        courseData['id'] = doc.id;

        // Fetch the students subcollection for the course
        QuerySnapshot studentsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(doc.id)
            .collection('enrolledCourses')
            .get();

        // Add students data to the course
        courseData['students'] = studentsSnapshot.docs.map((studentDoc) {
          return studentDoc.data() as Map<String, dynamic>;
        }).toList();

        fetchedCourses.add(courseData);
      }

      // Update state with the fetched data
      setState(() {
        _courses = fetchedCourses;
        _totalCourses = _courses.length;
        // _totalStudents = _courses.fold<int>(
        //   0, // Initial sum is 0
        //   (sum, course) => sum + (course['enrolledCourses']?.length ?? 0), // Ensures the return type is int
        // );
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
           
            // ListTile(
            //   title: Text('Course Analytics'),
            //   onTap: () {
            //     if (_courses.isNotEmpty) {
            //       String courseTitle = _courses[0]['title'] ?? 'Default Course Title';
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CourseAnalyticsScreen(courseTitle: courseTitle),
            //         ),
            //       );
            //     } else {
            //       print('No courses available');
            //     }
            //   },
            // ),
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
    List<dynamic> students = course['students'] ?? [];

    return ExpansionTile(
      title: Text(course['title'] ?? 'Untitled Course'),
      subtitle: Text('${students.length} Students'),
      children: students.map((student) {
        return ListTile(
          title: Text(student['name'] ?? 'Unnamed Student'),
          subtitle: Text(student['email'] ?? 'No Email Provided'),
        );
      }).toList(),
    );
  }
}
