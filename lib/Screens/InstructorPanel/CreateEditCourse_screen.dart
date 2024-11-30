/*
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';  // For permission handling
import '../../Custom_Widgets/CustomTextField.dart';
import '../../Custom_Widgets/GradientButton.dart';

class CreateEditCourseScreen extends StatefulWidget {
  @override
  _CreateEditCourseScreenState createState() => _CreateEditCourseScreenState();
}

class _CreateEditCourseScreenState extends State<CreateEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String courseTitle = '';
  String courseDescription = '';
  double coursePrice = 0.0;
  int courseDuration = 0;
  bool isPublished = false;
  List<String> mediaFiles = [];
  bool isUploading = false;

  // Method to pick files for media upload
  void _pickFiles() async {
    // Request storage permission for Android
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
      if (result != null) {
        setState(() {
          mediaFiles.addAll(result.paths.where((path) => path != null).cast<String>());
        });
      }
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied')));
    }
  }

  // Method to simulate media upload
  void _uploadMedia() async {
    setState(() {
      isUploading = true;
    });
    // Simulate a delay for uploading media
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create/Edit Course'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    hintText: 'Course Title',
                    icon: Icons.title,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    onSaved: (value) => courseTitle = value ?? '',
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
        
                  CustomTextField(
                    hintText: 'Course Description',
                    icon: Icons.description,
                    keyboardType: TextInputType.multiline,
                    obscureText: false,
                    maxLines: null,  // Allows the text field to expand
                    onSaved: (value) => courseDescription = value ?? '',
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
        
                  CustomTextField(
                    hintText: 'Course Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    onSaved: (value) => coursePrice = double.tryParse(value ?? '') ?? 0.0,
                    validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Please enter a valid price' : null,
                  ),
        
                  CustomTextField(
                    hintText: 'Course Duration (in hours)',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    onSaved: (value) => courseDuration = int.tryParse(value ?? '') ?? 0,
                    validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Please enter a valid duration' : null,
                  ),
        
                  // Course Media
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Course Media (Videos, Images, Documents):'),
                      ElevatedButton(
                        onPressed: _pickFiles,
                        child: Text('Upload Files'),
                      ),
                      if (mediaFiles.isNotEmpty)
                        ...mediaFiles.map((file) => Text(file)).toList(),
                      if (isUploading)
                        LinearProgressIndicator(),
                    ],
                  ),
        
                  // Publish/Unpublish Toggle
                  SwitchListTile(
                    title: Text('Publish Course'),
                    value: isPublished,
                    onChanged: (value) => setState(() {
                      isPublished = value;
                    }),
                  ),
        
                  // Action Buttons (Using GradientButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientButton(
                        buttonText: 'Save Draft',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            // Save as draft logic
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course Saved as Draft')));
                          }
                        },
                        gradientColors: [Colors.blueAccent.shade700, Colors.blue.shade500],
                      ),
                      GradientButton(
                        buttonText: 'Publish',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            // Publish course logic
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course Published')));
                          }
                        },
                        gradientColors: [Colors.green.shade700, Colors.green.shade500],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
