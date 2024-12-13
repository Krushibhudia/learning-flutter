import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseAnalyticsScreen extends StatelessWidget {
  // Constructor to initialize the screen
  CourseAnalyticsScreen({super.key, required String courseTitle});

  // Function to fetch all courses and their enrolled students' userIds
  Future<List<Map<String, dynamic>>> fetchCoursesWithStudents() async {
    try {
      // Fetch all courses from Firestore
      final courseSnapshot = await FirebaseFirestore.instance
          .collection('courses') // Collection name
          .get();

      if (courseSnapshot.docs.isEmpty) {
        throw 'No courses found';
      }

      List<Map<String, dynamic>> coursesData = [];

      // Iterate through all course documents
      for (var courseDoc in courseSnapshot.docs) {
        final courseData = courseDoc.data();
        final courseTitle = courseData['title'] ?? 'Unknown Course';
        
        // Ensure that 'enrolledStudents' is a list
        final List<dynamic> studentsList = courseData['enrolledCourses'] ?? [];

        // Add the count of students to the list
        final studentCount = studentsList.length;

        coursesData.add({
          'courseTitle': courseTitle,
          'studentCount': studentCount,  // Store the total number of students
        });
      }

      return coursesData; // Return the list of courses with studentCount
    } catch (e) {
      print('Error fetching courses and students: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses Analytics'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Courses and Total Enrolled Students',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>( 
                future: fetchCoursesWithStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No courses available'));
                  } else {
                    final courses = snapshot.data!;
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final courseTitle = course['courseTitle'] ?? 'Unknown Course';
                        final studentCount = course['studentCount'] ?? 0;

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(courseTitle),
                            subtitle: Text(
                              'Total Students: $studentCount',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
