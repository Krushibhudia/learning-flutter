import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/Screens/StudentPanel/Quiz_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../Custom_Widgets/CustomTextField.dart';
import '../../../Custom_Widgets/GradientButton.dart';
import '../ManageCourse_screen.dart';
import 'PreviewCourse_Screen.dart';

class CreateCourseScreen extends StatefulWidget {
  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  final TextEditingController _courseCategoryController = TextEditingController();

  bool _isCoursePublished = false;
  String _courseFormat = 'Video';
  String? _selectedCategory;
  File? image;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _categories = ['Design', 'Technology', 'Business', 'Art'];

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    super.dispose();
  }

  Future pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        image = File(pickedFile.path);
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> saveCourse() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user logged in. Please log in first.')));
      return;
    }

    String? imageUrl;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    try {
      String imageFileName = 'courses/${DateTime.now().millisecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref(imageFileName).putFile(image!);
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      String courseId = _firestore.collection('courses').doc().id;
      Map<String, dynamic> courseData = {
        'title': _courseTitleController.text,
        'description': _courseDescriptionController.text,
        'price': _coursePriceController.text,
        'category': _selectedCategory,
        'format': _courseFormat,
        'isPublished': _isCoursePublished,
        'instructorId': user.uid,
        'createdAt': Timestamp.now(),
        'image': imageUrl,
      };

      await _firestore.collection('courses').doc(courseId).set(courseData);
      await _firestore.collection('users').doc(user.uid).collection('courses').doc(courseId).set(courseData);

      Map<String, dynamic> quizData = {
        'courseId': courseId,
        'questions': [],
        'createdAt': Timestamp.now(),
      };
      await _firestore.collection('quizzes').doc(courseId).set(quizData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course saved successfully!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(courseId: courseId,)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving course: $e')));
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Course'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageLessonsScreen()),
            );
          },
          icon: Icon(Icons.edit_note),
        ),
      ],),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(hintText: 'Course Title', icon: Icons.title, keyboardType: TextInputType.text, obscureText: false, maxLines: 1, controller: _courseTitleController, isRequired: true, labelText: ''),
              SizedBox(height: 16),
              CustomTextField(hintText: 'Course Description', icon: Icons.description, keyboardType: TextInputType.text, obscureText: false, controller: _courseDescriptionController, maxLines: null, isRequired: true, labelText: ''),
              SizedBox(height: 16),
              CustomTextField(hintText: 'Course Price', icon: Icons.attach_money, keyboardType: TextInputType.number, obscureText: false, maxLines: 1, controller: _coursePriceController, isRequired: true, labelText: ''),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Course Category', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _courseFormat,
                items: ['Video', 'Live Session', 'Text-based'].map((format) => DropdownMenuItem(value: format, child: Text(format))).toList(),
                onChanged: (value) {
                  setState(() {
                    _courseFormat = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Course Format', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 20),
              image != null
                  ? Image.file(image!, width: 350, height: 160, fit: BoxFit.fill)
                  : Image.asset(Constants.logo, width: 350, height: 160, fit: BoxFit.fill),
              SizedBox(height: 10),
              ElevatedButton(onPressed: () => _showBottomSheet(context), child: Text('Pick an Image')),
              SizedBox(height: 20),
         
              
              GradientButton(
                onPressed: saveCourse,
                buttonText: 'Save Course',
                gradientColors: [Colors.blue, Colors.blue],
                label: '',
                child: Text(""),
              ),
            ],
          ),
        ),
      ),
    );
  }
}