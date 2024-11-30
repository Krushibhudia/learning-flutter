import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/authentication/Login_Screen.dart';

import '../authentication/EditProfile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss dialog with no action
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss dialog and confirm logout
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
    if (confirmLogout == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('sessions')
              .doc(user.uid)
              .update({'isLoggedIn': false});
        }
        await FirebaseAuth.instance.signOut();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.toString()}')),
        );
      }
    }
  }
  Future<void> _handleDeleteAccount(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action is irreversible."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();

                    await FirebaseFirestore.instance
                        .collection('sessions')
                        .doc(user.uid)
                        .delete();

                    await user.delete();

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
                    SnackBar(content: Text('Error deleting account: ${e.toString()}')),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Section
            Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/avatar.png"),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen()));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Courses Enrolled', '25'),
                  _buildStatCard('Courses Completed', '5'),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            _buildListTile(Icons.lock, 'Change Password', () {
              // Navigate to Change Password screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.notifications, 'Notifications', () {
              // Navigate to Notifications settings screen
            }),

            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.history, 'Course History', () {
              // Navigate to Course History screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.star, 'Favorites', () {
              // Navigate to Favorites screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.info, 'About App', () {
              // Show app information
            }),
            const SizedBox(
              height: 5,
            ),
            // Settings and Additional Options
            _buildListTile(Icons.settings, 'Settings', () {
              // Navigate to settings screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.help_outline, 'Help & Support', () {
              // Navigate to help and support screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.question_answer_outlined, 'FAQs', () {
              // Navigate to help and support screen
            }),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(
                Icons.logout, 'Logout', () => _handleLogout(context)),
            const SizedBox(
              height: 5,
            ),
            _buildListTile(Icons.delete, 'Delete Account', () {
              _handleDeleteAccount(context);            }),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build statistic cards
  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.blueAccent.shade100,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build ListTile with an onTap callback
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        onTap: onTap,
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        ),
      ),
    );
  }
}
