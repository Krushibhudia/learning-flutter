import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../../Custom_Widgets/CustomTextField.dart';
import '../../../Custom_Widgets/GradientButton.dart';
import '../ManageCourse_screen.dart';
import 'PreviewCourse_Screen.dart';

class CourseManagementScreen extends StatefulWidget {
  @override
  _CourseManagementScreenState createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController =
  TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  final TextEditingController _courseCategoryController =
  TextEditingController();

  bool _isCoursePublished = false;
  String _courseFormat = 'Video';
  String? _selectedCategory;
  File? _courseImage;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Category options
  final List<String> _categories = ['Design', 'Technology', 'Business', 'Art'];

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    super.dispose();
  }



  Future<void> saveCourse() async {
    // Get the current user
    User? user = _auth.currentUser;

    if (user == null) {
      // If no user is logged in, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in. Please log in first.')),
      );
      return;
    }

    // Prepare course data
    Map<String, dynamic> courseData = {
      'title': _courseTitleController.text,
      'description': _courseDescriptionController.text,
      'price': _coursePriceController.text,
      'category': _selectedCategory,
      'format': _courseFormat,
      'isPublished': _isCoursePublished,
      'instructorId': user.uid, // Store the user's UID for reference
      'createdAt': Timestamp.now(),
      // Optionally, store the image URL if uploaded
      'image': _courseImage != null ? _courseImage!.path : null,
    };

    try {
      // Generate a custom ID for the course
      String courseId = _firestore.collection('courses').doc().id;

      // Store the course in the 'courses' collection using the generated ID
      await _firestore.collection('courses').doc(courseId).set(courseData);

      // Store the course under the user's UID in the 'users/{uid}/courses' collection using the same ID
      await _firestore.collection('users').doc(user.uid).collection('courses').doc(courseId).set(courseData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course saved successfully!')),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to lesson management screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageLessonsScreen()),
              );
            },
            icon: Icon(Icons.edit_note),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Create or Edit Course Section using CustomTextField
              CustomTextField(
                hintText: 'Course Title',
                icon: Icons.title,
                keyboardType: TextInputType.text,
                obscureText: false,
                maxLines: 1,
                controller: _courseTitleController,
              ),
              SizedBox(height: 16),

              CustomTextField(
                hintText: 'Course Description',
                icon: Icons.description,
                keyboardType: TextInputType.text,
                obscureText: false,
                controller: _courseDescriptionController,
                maxLines: null,
              ),
              SizedBox(height: 16),

              CustomTextField(
                hintText: 'Course Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                obscureText: false,
                maxLines: 1,
                controller: _coursePriceController,
              ),
              SizedBox(height: 16),

              // Dropdown for Course Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Course Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Course Format Dropdown
              DropdownButtonFormField<String>(
                value: _courseFormat,
                items: ['Video', 'Live Session', 'Text-based']
                    .map((format) => DropdownMenuItem(
                  value: format,
                  child: Text(format),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _courseFormat = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Course Format',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Image Picker Button
              ElevatedButton(
                onPressed: (){},
                child: Text('Pick Course Image'),
              ),

              SizedBox(height: 20),

              // Add/Edit Lessons Button
              GradientButton(
                buttonText: 'Add/Edit Lessons',
                onPressed: () {
                  // Navigate to lesson management screen
                },
                gradientColors: [Colors.blue, Colors.blueAccent],
              ),
              SizedBox(height: 20),

              // Manage Media Button
              GradientButton(
                buttonText: 'Manage Media (Videos, PDFs)',
                onPressed: () {
                  // Open media management screen
                },
                gradientColors: [Colors.blue, Colors.blueAccent],
              ),
              SizedBox(height: 20),

              // Publish/Unpublish Course
              SwitchListTile(
                title: Text('Publish Course'),
                value: _isCoursePublished,
                onChanged: (bool value) {
                  setState(() {
                    _isCoursePublished = value;
                  });
                },
                activeColor: Colors.blue,
              ),
              SizedBox(height: 20),

              // Course Preview Button
              GradientButton(
                buttonText: 'Preview Course',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoursePreviewScreen(
                        title: _courseTitleController.text,
                        description: _courseDescriptionController.text,
                        price: _coursePriceController.text,
                        category: _courseCategoryController.text,
                        format: _courseFormat,
                        lessons: [
                          {'title': 'Introduction to Flutter', 'duration': '10 mins'},
                          {'title': 'State Management Basics', 'duration': '20 mins'},
                        ],
                      ),
                    ),
                  );
                },
                gradientColors: [Colors.blue, Colors.blueAccent],
              ),
              SizedBox(height: 40),

              // Save Course Button
              GradientButton(
                buttonText: 'Save Course',
                onPressed: () {
                  saveCourse();  // Call the function to save the course
                },
                gradientColors: [Colors.orange, Colors.red],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
