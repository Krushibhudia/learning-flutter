import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentQuizScreen extends StatefulWidget {
  final String courseId;
  final String quizId;

  const StudentQuizScreen({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  @override
  _StudentQuizScreenState createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  late Future<Map<String, dynamic>> quizData;

  @override
  void initState() {
    super.initState();
    // Fetch quiz data using both courseId and quizId
    quizData = fetchQuizData(widget.courseId, widget.quizId);
  }

  Future<Map<String, dynamic>> fetchQuizData(String courseId, String quizId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return {
          'title': data['title'] ?? 'Untitled Quiz',
          'description': data['description'] ?? 'No description available',
          'questions': data['questions'] ?? [],
        };
      } else {
        throw 'Quiz not found';
      }
    } catch (e) {
      throw 'Error fetching quiz data: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: quizData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No quiz data available.'));
          }

          // Extract quiz data
          final quiz = snapshot.data!;
          final title = quiz['title'];
          final description = quiz['description'];
          final questions = List<Map<String, dynamic>>.from(quiz['questions'] ?? []);

          // Process questions to include correctAnswer
          final processedQuestions = questions.map((question) {
            final options = List<String>.from(question['options'] ?? []);
            final correctAnswerIndex = question['correctAnswerIndex'] ?? 0;

            return {
              'questionText': question['questionText'] ?? 'No question provided',
              'options': options,
              'correctAnswer': options.isNotEmpty ? options[correctAnswerIndex] : '',
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: processedQuestions.length,
                    itemBuilder: (context, index) {
                      final question = processedQuestions[index];
                      return QuizQuestionWidget(
                        questionText: question['questionText'],
                        options: question['options'],
                        correctAnswer: question['correctAnswer'],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuizQuestionWidget extends StatefulWidget {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  const QuizQuestionWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  String? selectedAnswer;
  bool isAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.options.map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: selectedAnswer,
                title: Text(option),
                onChanged: isAnswered
                    ? null
                    : (value) {
                        setState(() {
                          selectedAnswer = value;
                          isAnswered = true;
                        });
                      },
                subtitle: isAnswered
                    ? (selectedAnswer == widget.correctAnswer
                        ? const Text('Correct!', style: TextStyle(color: Colors.green))
                        : const Text('Incorrect!', style: TextStyle(color: Colors.red)))
                    : null,
              );
            }).toList(),
            if (isAnswered)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAnswered = false;
                      selectedAnswer = null;
                    });
                  },
                  child: const Text('Next Question'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
