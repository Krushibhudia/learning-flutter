import 'package:flutter/material.dart';
import 'package:flutterpro/Custom_Widgets/GradientButton.dart';

import 'Quiz_Screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseTitle;
  final String courseImage;
  final String courseDescription;
  final double courseProgress;
  final List<Map<String, String>> lectures;
  final List<Map<String, String>> quizzes;

  const CourseDetailScreen({
    super.key,
    required this.courseTitle,
    required this.courseImage,
    required this.courseDescription,
    this.courseProgress = 0.7,
    required this.lectures,
    required this.quizzes,
  });

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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 4),
                      Text('4.8',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      const SizedBox(width: 10),
                      const Icon(Icons.person, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 4),
                      Text('500+ Students',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Course Progress Section
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Course Progress',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: courseProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(courseProgress * 100).toInt()}% completed',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                  const SizedBox(height: 24),

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

                  // Course Content (Lectures)
                  const Text(
                    'Course Content',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lectures.length,
                    itemBuilder: (context, index) {
                      final lecture = lectures[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.play_circle_outline,
                              color: Colors.blueAccent),
                          title: Text(
                            lecture['title'] ?? 'Untitled Lecture',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            lecture['duration'] ?? 'Duration unknown',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quizzes Section
                  const Text(
                    'Quizzes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
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
                            quiz['title'] ?? 'Untitled Quiz',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Duration: ${quiz['duration'] ?? 'Unknown'}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.blueAccent),
                            onPressed: () {
                              // Navigate to the QuizScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    quizId: index,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Sticky Enroll Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: GradientButton(
                onPressed: () {
                  // Enroll Course logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enrolled successfully!')),
                  );
                },

                buttonText: 'Enroll Now', gradientColors: [
                  Colors.blue,
                Colors.blueAccent
              ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
