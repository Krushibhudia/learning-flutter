import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/InstructorDashBoard_Screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/Settings_Screen.dart';

import 'Analytics_screen.dart';
import 'CourseManage/CourseManagement_Screen.dart';
import 'Webinar_screen.dart';

class mainPanel extends StatefulWidget {
  const mainPanel({super.key});

  @override
  State<mainPanel> createState() => _mainPanelState();
}

class _mainPanelState extends State<mainPanel> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    InstructorDashboardScreen(),
    AnalyticsReportsPage(),
    CourseManagementScreen(),
    LiveSessionManagementScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'DashBoard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Course Manage',
          ),
             BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_front),
            label: 'Webinar',
          ),  BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),


        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent, // Color for the selected item
        unselectedItemColor: Colors.black54, // Color for the unselected items
      ),
    );
  }
}
