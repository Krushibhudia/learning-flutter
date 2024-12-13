import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Custom_Widgets/GradientButton.dart';
import 'package:flutterpro/Screens/StudentPanel/studentquizscreen.dart';
import 'Quiz_Screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  final String courseImage;
  final String courseDescription;
    final String userId; // Pass the userId to identify the user

  final List<Map<String, String>> lectures;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.courseImage,
    required this.courseDescription,
    required this.userId, // Add userId to constructor

    required this.lectures,
  }) : super(key: key);

  Future<void> enrollCourse(BuildContext context) async {
    // Show confirmation dialog
    bool confirmEnrollment = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Enrollment"),
          content: Text("Do you want to enroll in the course '$courseTitle'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmEnrollment) {
      // Show Snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrolled successfully!')),
      );

      try {
        // Update Firestore collections
        // Update user's enrolled courses
        FirebaseFirestore.instance.collection('users').doc(userId).update({
          'enrolledCourses': FieldValue.arrayUnion([courseId]),
        });

        // Update course's enrolled users
        FirebaseFirestore.instance.collection('courses').doc(courseId).update({
          'enrolledUsers': FieldValue.arrayUnion([userId]),
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling in the course: $e')),
        );
      }
    }
  }


  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled Quiz',
          'duration': data['duration'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          courseTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes: ${snapshot.error}'));
          }

          final quizzes = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      courseImage,
                      height: 220.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  

                  // Course Title and Info
                  Text(
                    courseTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Course Description
                  const Text(
                    'Course Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseDescription,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                   Align(
  alignment: Alignment.center,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    color: Colors.white,
    child: GradientButton(
      onPressed: () {
  enrollCourse(context); // Call enrollCourse on button press        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully!'),
        );
      },
      buttonText: 'Enroll Now',
      gradientColors: const [
        Colors.blue,
        Colors.blueAccent,
      ], label: '', child: Text(""), 
    ),
  ),
),
SizedBox(height: 8,),

                  // Quizzes Section
                  const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  quizzes.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizzes[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.quiz, color: Colors.blueAccent),
                                title: Text(
                                  quiz['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  'Duration: ${quiz['duration']}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
                                  onPressed: () {
                                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StudentQuizScreen(      courseId: courseId,
quizId: quiz['id']),
  ),
);

                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : const Text(
                          'No quizzes available for this course.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
