import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Custom_Widgets/CustomTextField.dart';
import '../../Custom_Widgets/GradientButton.dart';

class InstructorEditProfileScreen extends StatefulWidget {
  @override
  State<InstructorEditProfileScreen> createState() =>
      _InstructorEditProfileScreenState();
}

class _InstructorEditProfileScreenState
    extends State<InstructorEditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController expertiseController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            nameController.text = data['fullName'] ?? '';
            emailController.text = data['email'] ?? '';
            aboutController.text = data['about'] ?? '';
            expertiseController.text = data['expertise'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Your Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Picture Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150', // Replace with profile image URL
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    onPressed: () {
                      // Handle profile picture upload logic here
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Email',
              icon: Icons.email,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(height: 16),

            // Name Text Field
            CustomTextField(
              hintText: 'Full Name',
              icon: Icons.person,
              keyboardType: TextInputType.name,
              obscureText: false,
              controller: nameController,
            ),

            // Email Text Field

            const SizedBox(height: 16),

            // Expertise Field
            CustomTextField(
              hintText: 'Expertise (e.g., Technology, Design)',
              icon: Icons.school,
              keyboardType: TextInputType.text,
              obscureText: false,
              controller: expertiseController,
            ),
            const SizedBox(height: 16),

            // About Text Field
            CustomTextField(
              hintText: 'About You',
              icon: Icons.info_outline,
              keyboardType: TextInputType.multiline,
              obscureText: false,
              controller: aboutController,
              maxLines: 4,
            ),
            const SizedBox(height: 30),

            // Save Button
            GradientButton(
              buttonText: 'Save Changes',
              onPressed: () async {
                // Handle save logic here
                await _updateUserData();
                Navigator.pop(context);
              },
              gradientColors: [Colors.blue, Colors.blueAccent],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'about': aboutController.text.trim(),
          'expertise': expertiseController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print("Error updating user data: $e");
    }
  }
}
