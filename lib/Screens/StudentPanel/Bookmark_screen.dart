import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkScreen extends StatefulWidget {
  final List<String> bookmarkedCourses;  // Pass the bookmarked course IDs

  BookmarkScreen({required this.bookmarkedCourses});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<Map<String, dynamic>>> _bookmarkedCoursesFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedCoursesFuture = fetchBookmarkedCourses(widget.bookmarkedCourses);
  }

  Future<List<Map<String, dynamic>>> fetchBookmarkedCourses(List<String> bookmarkedCourses) async {
    if (bookmarkedCourses.isEmpty) return [];

    // Fetch course details for the bookmarked courses
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where(FieldPath.documentId, whereIn: bookmarkedCourses)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarked Courses"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookmarkedCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading bookmarks"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text("No bookmarked courses"));
          }

          final bookmarkedCourses = snapshot.data!;
          return ListView.builder(
            itemCount: bookmarkedCourses.length,
            itemBuilder: (context, index) {
              final course = bookmarkedCourses[index];
              return ListTile(
                leading: course['image'] != null
                    ? Image.network(course['image'], width: 50, height: 50)
                    : Icon(Icons.book),
                title: Text(course['title'] ?? 'Untitled Course'),
                subtitle: Text(course['description'] ?? 'No description available'),
              );
            },
          );
        },
      ),
    );
  }
}
