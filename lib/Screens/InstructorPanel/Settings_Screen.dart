import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Settings
              SectionTitle(title: 'Notification Settings'),
              SettingToggle(
                title: 'Receive Email Notifications',
                value: true,
                onChanged: (value) {
                  // Handle toggle logic
                },
              ),
              SettingToggle(
                title: 'Receive Push Notifications',
                value: false,
                onChanged: (value) {
                  // Handle toggle logic
                },
              ),
              SizedBox(height: 16),

              // Privacy Settings
              SectionTitle(title: 'Privacy Settings'),
              SettingToggle(
                title: 'Allow profile visibility',
                value: true,
                onChanged: (value) {
                  // Handle toggle logic
                },
              ),
              SettingToggle(
                title: 'Allow course visibility',
                value: false,
                onChanged: (value) {
                  // Handle toggle logic
                },
              ),
              SizedBox(height: 16),

              // Language Preferences
              SectionTitle(title: 'Language Preferences'),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              SizedBox(height: 16),

              // Log Out Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle log out logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('Log Out', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for Section Titles
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// Widget for Toggle Settings
class SettingToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
