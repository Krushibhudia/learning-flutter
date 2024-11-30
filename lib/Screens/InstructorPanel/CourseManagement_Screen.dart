import 'package:flutter/material.dart';

import '../../Custom_Widgets/CustomTextField.dart';
import '../../Custom_Widgets/GradientButton.dart';
import 'ManageCourse_screen.dart';

// Course Management Screen
class CourseManagementScreen extends StatefulWidget {
  @override
  _CourseManagementScreenState createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  // Define form controllers
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescriptionController =
  TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  final TextEditingController _courseCategoryController =
  TextEditingController();

  bool _isCoursePublished = false; // For managing course publication status
  String _courseFormat = 'Video'; // Default format (could be Live session, etc.)

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ManageLessonsScreen()));
          }, icon: Icon(Icons.edit_note))
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

              CustomTextField(
                hintText: 'Course Category',
                icon: Icons.category,
                keyboardType: TextInputType.text,
                obscureText: false,
                maxLines: 1,
                controller: _courseCategoryController,
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
                  // Preview the course layout as it would appear to students
                },
                gradientColors: [Colors.blue, Colors.blueAccent],
              ),
              SizedBox(height: 40),

              // Save Course Button
              GradientButton(
                buttonText: 'Save Course',
                onPressed: () {
                  // Save course details to database (e.g., Firebase)
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
