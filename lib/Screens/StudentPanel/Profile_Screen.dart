import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/authentication/EditProfile_screen.dart';
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
  bool _isDeletingAccount = false;
  String? _profileImageUrl;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _fetchUserData();  // Fetch user data again when the app comes to the foreground
  }
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

  // Handle delete account
  Future<void> _handleDeleteAccount(BuildContext context) async {
    setState(() => _isDeletingAccount = true);

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action is permanent."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Delete user from Firestore
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();

          // Delete the profile image from Firebase Storage (optional)
          if (_profileImageUrl != null) {
            Reference ref = FirebaseStorage.instance.refFromURL(_profileImageUrl!);
            await ref.delete();
          }

          // Delete the user from Firebase Authentication
          await currentUser.delete();

          // Clear shared preferences and navigate to the login screen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      } finally {
        setState(() => _isDeletingAccount = false);
      }
    } else {
      setState(() => _isDeletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Profile',style: TextStyle(color: Colors.white),),
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
                     CircleAvatar(
  radius: 24, // Adjust the radius as needed
  backgroundColor: Colors.blueAccent, // Background color of the circle
  child: IconButton(
    icon: const Icon(
      Icons.edit,
      color: Colors.white,
      size: 28,
    ),
    onPressed: () {
      // Navigate to the EditProfileScreen when camera is clicked
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        ),
      );
    },
  ),
)

                    ],
                  ),
                ),
                const SizedBox(height: 20),
                                _buildListTile(Icons.privacy_tip, 'Privacy Policy', () {}),
                                _buildListTile(Icons.list_outlined, 'Terms & Conditions', () {}),

                _buildListTile(Icons.logout, 'Logout', () => _handleLogout(context)),
                _buildListTile(Icons.delete, 'Delete Account', () => _handleDeleteAccount(context)),
              ],
            ),
          ),
          if (_isLoggingOut || _isDeletingAccount) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add margin for spacing between cards
    elevation: 4, // Add shadow to give the card a floating effect
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners for the tile
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: Colors.blueAccent, // Icon color
        size: 28, // Adjust icon size for better visibility
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16, // Larger text for readability
          fontWeight: FontWeight.bold, // Bold for emphasis
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios, // A forward arrow icon indicating navigation
        color: Colors.grey, // Subtle color for the trailing icon
        size: 20, // Adjust size of the arrow icon
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Padding inside the ListTile
    ),
  );
}

}
