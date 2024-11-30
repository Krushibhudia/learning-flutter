import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // For calendar widget

class LiveSessionManagementScreen extends StatefulWidget {
  @override
  _LiveSessionManagementScreenState createState() =>
      _LiveSessionManagementScreenState();
}

class _LiveSessionManagementScreenState
    extends State<LiveSessionManagementScreen> {
  // Define the current date and selected date
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Class & Webinar Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar View
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Create New Session FAB (Floating Action Button)
            FloatingActionButton(
              onPressed: () {
                // Navigate to Create Session Screen
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
              elevation: 10, // Added shadow for depth
              hoverElevation: 15, // Elevated effect when hovered
              highlightElevation: 15, // Elevated effect when pressed
              splashColor: Colors.blueAccent, // Color when tapped
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded corners
              ),
            ),
            SizedBox(height: 20),

            // Manage Active Session
            Column(
              children: [
                // Active Session Controls (Start, End, Record)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSessionButton('Start Session', Colors.green, () {
                      // Start the session
                    }),
                    SizedBox(width: 10),
                    _buildSessionButton('End Session', Colors.red, () {
                      // End the session
                    }),
                  ],
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('Record Session'),
                  value: true, // Set to true/false dynamically
                  onChanged: (value) {
                    // Toggle recording state
                  },
                  activeColor: Colors.blue, // Change the switch color
                ),
              ],
            ),
            SizedBox(height: 20),

            // Manage Participants
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10, // Replace with dynamic participant count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Participant ${index + 1}'),
                  subtitle: Text('Status: Waiting'),
                  trailing: _buildJoinButton(() {
                    // Allow participant to join
                  }),
                );
              },
            ),
            SizedBox(height: 20),

            // Live Chat Section
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter message...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message), // Icon before input
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Send message
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded button
                    ),
                  ),
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create session buttons with consistent style
  ElevatedButton _buildSessionButton(String title, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded button
        ),
        elevation: 8, // Button shadow
        shadowColor: color.withOpacity(0.5), // Subtle shadow
      ),
      child: Text(title,style: TextStyle(color: Colors.white),),
    );
  }

  // Helper method for the "Join" button
  ElevatedButton _buildJoinButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text('Join',style: TextStyle(color: Colors.white),),
    );
  }
}
