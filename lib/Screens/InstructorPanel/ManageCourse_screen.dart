import 'package:flutter/material.dart';

class ManageLessonsScreen extends StatefulWidget {
  @override
  _ManageLessonsScreenState createState() => _ManageLessonsScreenState();
}

class _ManageLessonsScreenState extends State<ManageLessonsScreen> {
  List<Map<String, String>> lessons = [
    {'title': 'Lesson 1', 'duration': '5 min'},
    {'title': 'Lesson 2', 'duration': '10 min'},
    {'title': 'Lesson 3', 'duration': '7 min'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Lessons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save all lessons logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add New Lesson Button
            ElevatedButton(
              onPressed: () {
                // Add new lesson logic
                setState(() {
                  lessons.add({'title': 'New Lesson', 'duration': '0 min'});
                });
              },
              child: const Text('Add New Lesson'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of Lessons
            Expanded(
              child: ListView.builder(
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(lessons[index]['title']!),
                    onDismissed: (direction) {
                      setState(() {
                        lessons.removeAt(index);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(Icons.book),
                        title: Text(lessons[index]['title']!),
                        subtitle: Text('Duration: ${lessons[index]['duration']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  lessons.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _showLessonPreview(context, index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog for editing a lesson
  void _showEditDialog(BuildContext context, int index) {
    TextEditingController titleController =
    TextEditingController(text: lessons[index]['title']);
    TextEditingController durationController =
    TextEditingController(text: lessons[index]['duration']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lesson'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Lesson Title'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Lesson Duration'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  lessons[index]['title'] = titleController.text;
                  lessons[index]['duration'] = durationController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show lesson preview
  void _showLessonPreview(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Preview: ${lessons[index]['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Duration: ${lessons[index]['duration']}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Handle preview or play video
                },
                child: const Text('Preview Lesson'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

