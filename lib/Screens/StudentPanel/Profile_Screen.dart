import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  String? _profileImageUrl;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch current user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          setState(() {
            _profileImageUrl = userDoc['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Pick an image from the gallery
  Future<void> _pickProfileImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _profileImageFile = File(pickedFile.path);
    });
    _showImagePreviewDialog();
  }
}

// Show a dialog to preview the selected image and confirm the upload
void _showImagePreviewDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Preview Image"),
        content: _profileImageFile != null
            ? Image.file(_profileImageFile!)
            : const Text("No image selected."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadProfileImage();
            },
            child: const Text("Upload"),
          ),
        ],
      );
    },
  );
}


  // Upload the profile image to Firebase Storage and update Firestore
  Future<void> _uploadProfileImage() async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(_profileImageFile!);
      String downloadUrl = await ref.getDownloadURL();

      // Update the user's profile image URL in Firestore
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  // Handle logout
  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoggingOut = true);

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      } finally {
        setState(() => _isLoggingOut = false);
      }
    } else {
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage("assets/avatar.png") as ImageProvider,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                        onPressed: _pickProfileImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildListTile(Icons.logout, 'Logout', () => _handleLogout(context)),
              ],
            ),
          ),
          if (_isLoggingOut) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      onTap: onTap,
    );
  }
}
