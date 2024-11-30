import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              // Handle log out logic
            }),

            const SizedBox(height: 20),

            // Delete Account Button
            _buildActionButton('Delete Account', Colors.blueAccent, () {
              // Handle delete account logic
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
