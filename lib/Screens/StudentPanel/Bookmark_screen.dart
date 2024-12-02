import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CourseDetail_screen.dart';

class BookmarkedScreen extends StatefulWidget {
  const BookmarkedScreen({Key? key}) : super(key: key);

  @override
  _BookmarkedScreenState createState() => _BookmarkedScreenState();
}

class _BookmarkedScreenState extends State<BookmarkedScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredBookmarkedCourses = [];
  List<Map<String, dynamic>> bookmarkedCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookmarkedCourses();
    _searchController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCourses);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookmarkedCourses() async {
    try {
      final userId = _firebaseAuth.currentUser; // Replace with actual user ID
      final userBookmarksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId as String?)
          .collection('bookmarkedCourses')
          .get();

      final bookmarkedIds =
      userBookmarksSnapshot.docs.map((doc) => doc.id).toList();

      if (bookmarkedIds.isNotEmpty) {
        final coursesSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .where(FieldPath.documentId, whereIn: bookmarkedIds)
            .get();

        setState(() {
          bookmarkedCourses = coursesSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
          filteredBookmarkedCourses = bookmarkedCourses;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching bookmarked courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBookmarkedCourses = bookmarkedCourses
          .where((course) => course['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 5.0),
                  child: Text(
                    "Your Bookmarks",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 15.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search bookmarked courses',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: filteredBookmarkedCourses.isEmpty
            ? const Center(
          child: Text(
            "No bookmarked courses available",
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: filteredBookmarkedCourses.length,
          itemBuilder: (context, index) {
            final course = filteredBookmarkedCourses[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseTitle: course['title'],
                      courseImage: course['image'],
                      courseDescription: course['description'],
                      courseProgress: 0.7,
                      lectures: course['lectures'],
                      quizzes: course['quizzes'],
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image'],
                          height: 70.0,
                          width: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  "${course['rating']} Rating",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
