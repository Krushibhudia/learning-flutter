import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterpro/Screens/StudentPanel/Bookmark_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> courses = [
    {"courseId": "course1", "title": "Course 1", "image": "https://via.placeholder.com/150"},
    {"courseId": "course2", "title": "Course 2", "image": "https://via.placeholder.com/150"},
    {"courseId": "course3", "title": "Course 3", "image": "https://via.placeholder.com/150"},
  ];

  // Add or remove the courseId from the user's bookmarks
  void _toggleBookmark(BuildContext context, String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    // Fetch current bookmarks
    List<String> bookmarkedCourses = List<String>.from(userDoc.data()?['bookmarkedCourses'] ?? []);

    // Add or remove bookmark
    if (bookmarkedCourses.contains(courseId)) {
      bookmarkedCourses.remove(courseId);  // Remove bookmark
    } else {
      bookmarkedCourses.add(courseId);  // Add bookmark
    }

    // Update Firestore with new bookmarks
    await userDocRef.update({'bookmarkedCourses': bookmarkedCourses});

    // Optionally navigate to Bookmark Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookmarkScreen(bookmarkedCourses: bookmarkedCourses)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return ListTile(
            leading: Image.network(course['image']!),
            title: Text(course['title']!),
            trailing: IconButton(
              icon: Icon(Icons.bookmark_border),
              onPressed: () {
                _toggleBookmark(context, course['courseId']!);
              },
            ),
          );
        },
      ),
    );
  }
}
