import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/Login_Screen.dart';
import 'GenerateStudentCerticate_Screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  // Boolean values to manage the switch states
  bool receiveEmailNotifications = true;
  bool receivePushNotifications = false;
  bool allowProfileVisibility = true;
  bool allowCourseVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>CertificatesScreen()));
            }, icon: Icon(Icons.celebration_outlined))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Notification Settings Section
            _buildSectionTitle('Notification Settings'),
            _buildSettingToggle(
                'Receive Email Notifications', receiveEmailNotifications,
                    (newValue) {
                  setState(() {
                    receiveEmailNotifications = newValue;
                  });
                }),
            _buildSettingToggle(
                'Receive Push Notifications', receivePushNotifications,
                    (newValue) {
                  setState(() {
                    receivePushNotifications = newValue;
                  });
                }),

            const SizedBox(height: 20),

            // Privacy Settings Section
            _buildSectionTitle('Privacy Settings'),
            _buildSettingToggle(
                'Allow Profile Visibility', allowProfileVisibility,
                    (newValue) {
                  setState(() {
                    allowProfileVisibility = newValue;
                  });
                }),
            _buildSettingToggle(
                'Allow Course Visibility', allowCourseVisibility,
                    (newValue) {
                  setState(() {
                    allowCourseVisibility = newValue;
                  });
                }),

            const SizedBox(height: 20),

            // Language Preferences Section
            _buildSectionTitle('Language Preferences'),
            _buildLanguageDropdown(),

            const SizedBox(height: 20),

            // Log Out Button
            _buildActionButton('Log Out', Colors.blueAccent, () {
              _handleLogout(context);
            }),

            const SizedBox(height: 20),

            // Delete Account Button
            _buildActionButton('Delete Account', Colors.blueAccent, () {
              _handleDeleteAccount(context);
            }),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Toggle Setting Widget
  Widget _buildSettingToggle(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  // Language Dropdown Widget
  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Language',
          labelStyle: const TextStyle(fontSize: 16),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
        value: 'English',
        items: ['English', 'Spanish', 'French', 'German']
            .map((lang) => DropdownMenuItem<String>(
          value: lang,
          child: Text(lang),
        ))
            .toList(),
        onChanged: (value) {
          // Handle language change
        },
      ),
    );
  }

  // Action Button Widget (Log Out/Delete Account)
  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),
    );
  }
}
