import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CourseDetail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  Set<String> bookmarkedCourses = {}; // Tracks bookmarked course IDs

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch the username and bookmarked courses from Firestore
  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc.data()?['fullName'] ?? 'User';
        bookmarkedCourses = Set<String>.from(userDoc.data()?['bookmarkedCourses'] ?? []);
      });
    }
  }

  // Toggle bookmark for a course
  Future<void> _toggleBookmark(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      List<String> currentBookmarks = List<String>.from(bookmarkedCourses);

      if (currentBookmarks.contains(courseId)) {
        currentBookmarks.remove(courseId); // Unbookmark
      } else {
        currentBookmarks.add(courseId); // Bookmark
      }

      // Update Firestore with the new bookmark list
      await userRef.update({
        'bookmarkedCourses': currentBookmarks,
      });

      setState(() {
        bookmarkedCourses = Set<String>.from(currentBookmarks); // Update local state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: Stack(
          children: [
            _buildAppBarBackground(),
            _buildSearchBar(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildCourseList(),
      ),
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
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
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName != null ? "Hi $userName," : "Hi there,",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Welcome back!",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
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
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search courses by title',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No courses available.'));
        }

        final courses = snapshot.data!.docs;
        final filteredCourses = courses.where((course) {
          final title = (course['title'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery);
        }).toList();

        if (filteredCourses.isEmpty) {
          return const Center(child: Text('No matching courses found.'));
        }

        return ListView.builder(
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            var course = filteredCourses[index];
            return _buildCourseCard(course);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(QueryDocumentSnapshot course) {
    final courseId = course.id;
    final courseTitle = course['title'] ?? 'No Title';
    final courseDescription = course['description'] ?? 'No Description available';
    final courseCategory = course['category'] ?? 'Uncategorized';
    final coursePrice = course['price'] ?? '0';
    final courseImage = course['image'] ?? ''; // Fetch the image URL

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: courseImage.isNotEmpty
            ? Image.network(courseImage, width: 50, height: 50, fit: BoxFit.cover) // Display image if available
            : const Icon(Icons.book, size: 50, color: Colors.grey), // Fallback icon if no image
        title: Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseCategory, style: const TextStyle(color: Colors.grey)),
            Text('\$${coursePrice}', style: const TextStyle(color: Colors.green)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            bookmarkedCourses.contains(courseId) ? Icons.bookmark : Icons.bookmark_outline,
            color: bookmarkedCourses.contains(courseId) ? Colors.red : Colors.grey,
          ),
          onPressed: () => _toggleBookmark(courseId),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(
                courseTitle: courseTitle,
                courseDescription: courseDescription,
                courseImage: courseImage,
                quizzes: const [],
                lectures: const [],
              ),
            ),
          );
        },
      ),
    );
  }
}
