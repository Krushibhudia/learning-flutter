import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CourseEditScreen.dart';
import 'package:flutterpro/Screens/InstructorPanel/CourseManage/CreateCourse_Screen.dart';

class ManageCourseScreen extends StatefulWidget {
  @override
  _ManageCourseScreenState createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends State<ManageCourseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user logged in.')));
      return;
    }

    try {
      QuerySnapshot courseSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .get();

      setState(() {
        courses = courseSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching courses: $e')));
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
    // Delete from user's courses collection
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('courses')
        .doc(courseId)
        .delete();

    // Delete from the main 'courses' collection
    await _firestore
        .collection('courses')
        .doc(courseId)
        .delete();

    // Update the local state to reflect the deletion
    setState(() {
      courses.removeWhere((course) => course['id'] == courseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course deleted successfully!.')));
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

              child: Text('Cancel',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete',style: TextStyle(color: Colors.white),
            ),),
          ],
        ),
      ) ??
      false; // Default to false if the dialog is dismissed
}


  void _editCourse(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditCourseScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Courses'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? Center(child: Text('No courses found.'))
              : GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseCard(
                      course: course,
                      onEdit: () => _editCourse(course),
                      onDelete: () => _deleteCourse(course['id']),
                    );
                  },
                ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        child: Text('Edit',style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDelete,
                        child: Text('Delete',style: TextStyle(fontSize: 11),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                                                    foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
