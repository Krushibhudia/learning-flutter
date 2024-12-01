import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'CourseDetail_screen.dart';
import 'Notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();

  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = userDoc.data()?['fullName'] ?? 'User'; // Fallback to 'User' if no name
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(150.0), // Adjusted for the new layout
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
            ),
            // Positioned Search Bar
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 15.0, // Position it near the bottom of the AppBar
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: buildCourseList(),
      ));
  }

  // Course List
  Widget buildCourseList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(
                  quizzes: [
                  {'title': 'JavaScript Quiz 1', 'duration': '10 min'},
                  {'title': 'JavaScript Quiz 2', 'duration': '15 min'},
                  ],
                  courseTitle: "Course Title ${index + 1}",
                  courseImage:
                      'https://s.tmimgcdn.com/scr/1600x1000/87300/edugroit-online-course-website-template-wordpress-theme_87334-3-original.png',
                  courseDescription: 'Description of Course ${index + 1}',
                  lectures: const [
                    {
                      'title': 'Lecture 1',
                      'instructor': 'Instructor A',
                      'duration': '10 mins'
                    },
                    {
                      'title': 'Lecture 2',
                      'instructor': 'Instructor B',
                      'duration': '20 mins'
                    },
                  ],
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://s.tmimgcdn.com/scr/1600x1000/87300/edugroit-online-course-website-template-wordpress-theme_87334-3-original.png',
                      height: 60.0,
                      width: 80.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course Title ${index + 1}",
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0),
                        const Row(
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book_rounded,
                                      color: Colors.green, size: 16.0),
                                  SizedBox(width: 4.0),
                                  Flexible(
                                    child: Text(
                                      "15 Lessons",
                                      style: TextStyle(fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0), // Space between items
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(Icons.star_border,
                                      color: Colors.orange, size: 16.0),
                                  SizedBox(width: 4.0),
                                  Flexible(
                                    child: Text(
                                      "4.5 Rating",
                                      style: TextStyle(fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0), // Space between items
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(Icons.person_3_outlined,
                                      color: Colors.deepPurple, size: 16.0),
                                  SizedBox(width: 4.0),
                                  Flexible(
                                    child: Text(
                                      "1500 Enrolled",
                                      style: TextStyle(fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
    );
  }
}
