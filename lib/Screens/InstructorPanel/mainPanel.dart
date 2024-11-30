import 'package:flutter/material.dart';
import 'package:flutterpro/Screens/InstructorPanel/CreateEditCourse_screen.dart';
import 'package:flutterpro/Screens/InstructorPanel/InstructorDashBoard_Screen.dart';

class mainPanel extends StatefulWidget {
  const mainPanel({super.key});

  @override
  State<mainPanel> createState() => _mainPanelState();
}

class _mainPanelState extends State<mainPanel> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    InstructorDashboardScreen(),
    CreateEditCourseScreen(),
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
            icon: Icon(Icons.bookmark),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
