import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final Set<String> bookmarkedCourses = {}; // Tracks bookmarked course IDs

  @override
  void initState() {
    super.initState();
    _fetchUserName();

    // Listen to search query changes
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

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc.data()?['fullName'] ?? 'User';
      });
    }
  }

 void _toggleBookmark(String courseId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    // Fetch current bookmarks from Firestore
    final userDoc = await userRef.get();
    List<String> bookmarkedCourses = List<String>.from(userDoc.data()?['bookmarkedCourses'] ?? []);
    
    // Toggle the bookmark status
    setState(() {
      if (bookmarkedCourses.contains(courseId)) {
        bookmarkedCourses.remove(courseId); // Remove bookmark
      } else {
        bookmarkedCourses.add(courseId); // Add bookmark
      }
    });
    
    // Update the Firestore database with the new list of bookmarked courses
    await userRef.update({
      'bookmarkedCourses': bookmarkedCourses,
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: const Icon(Icons.book, size: 50, color: Colors.grey), // Remove image handling
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
                courseImage: '', // Placeholder as image is removed
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
