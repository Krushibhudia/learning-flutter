import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CreateCourse_Screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/ManageCourse.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CourseAnalytics.dart';
import 'package:flutterpro/Screens/StudentPanel/Profile_Screen.dart';
import 'package:flutterpro/Screens/StudentPanel/Quiz_Screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User's course data
  List<Map<String, dynamic>> _courses = [];
  int _totalStudents = 0;
  int _totalCourses = 0;
  bool isLoading = true;

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

      // Fetch all courses and their student count from the enrolledUsers field
      List<Map<String, dynamic>> fetchedCourses = [];
      int totalStudentsCount = 0;

      // Iterate through all course documents
      for (var doc in courseSnapshot.docs) {
        Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
        courseData['id'] = doc.id;

        // Fetch the enrolledUsers field (list of student IDs)
        List<dynamic> enrolledUsers = courseData['enrolledUsers'] ?? [];
        print("Course ID: ${doc.id}, Enrolled Users: $enrolledUsers");

        // Check if enrolledUsers is a list and count the length
        int studentCount = 0;
        if (enrolledUsers is List) {
          studentCount = enrolledUsers.length; // Get the number of students
        } else {
          print("Invalid enrolledUsers format for course ${doc.id}");
        }

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
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching instructor data: $e");
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user logged in.')));
      return;
    }

    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc(courseId)
          .delete();

      await _firestore
          .collection('courses')
          .doc(courseId)
          .delete();

      setState(() {
        _courses.removeWhere((course) => course['id'] == courseId);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course deleted successfully!')));
    } catch (e) {
      print('Error deleting course: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting course: $e')));
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete this course? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
  }

  void _editCourse(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCourseScreen(),
      ),
    );
  }

  void _addQuiz(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instructor Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen()));
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
              // Manage Courses Section
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                      ? Center(child: Text('No courses found.'))
                      : GridView.builder(
                          padding: EdgeInsets.all(4.0),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 1.0,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return CourseCard(
                              course: course,
                              onEdit: () => _editCourse(course),
                              onDelete: () => _deleteCourse(course['id']),
                              onAddQuiz: () => _addQuiz(course['id']),
                            );
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
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddQuiz;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
    required this.onAddQuiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              course['image'] ?? 'https://via.placeholder.com/150',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] ?? 'Untitled',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  course['category'] ?? 'Uncategorized',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        child: Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDelete,
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onAddQuiz,
                  child: Text('Add Quiz'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
