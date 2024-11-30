import 'dart:async';
import 'package:flutter/material.dart';

import 'Certificate_Screen.dart';

class QuizScreen extends StatefulWidget {
  final int quizId;

  const QuizScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();}

class _QuizScreenState extends State<QuizScreen> {
late List<Map<String, dynamic>> questions;
int currentQuestionIndex = 0;
int score = 0;
Timer? questionTimer;
int timeLeft = 60;
bool quizCompleted = false;

@override
void initState() {
super.initState();
questions = _loadQuizQuestions(widget.quizId);
_startTimer();
}

@override
void dispose() {
questionTimer?.cancel();
super.dispose();
}

void _startTimer() {
questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
if (timeLeft > 0) {
setState(() {
timeLeft--;
});
} else {
_nextQuestion();
}
});
}

void _nextQuestion() {
if (currentQuestionIndex < questions.length - 1) {
setState(() {
currentQuestionIndex++;
timeLeft = 60; // Reset timer for the next question
});
} else {
_finishQuiz();
}
}

void _finishQuiz() {
questionTimer?.cancel();
setState(() {
quizCompleted = true;
});
}

List<Map<String, dynamic>> _loadQuizQuestions(int quizId) {
return [
{
'question': 'What is Flutter?',
'options': [
'A mobile framework',
'A programming language',
'A database',
'None of the above'
],
'correctAnswer': 0,
},
{
'question': 'What is Dart?',
'options': ['A language', 'A framework', 'A tool', 'None of the above'],
'correctAnswer': 0,
},
{
'question': 'Which company developed Flutter?',
'options': ['Google', 'Facebook', 'Apple', 'Microsoft'],
'correctAnswer': 0,
},
{
'question': 'Which of the following is a feature of Flutter?',
'options': [
'Cross-platform development',
'Single platform development',
'No UI',
'None of the above'
],
'correctAnswer': 0,
},
{
'question':
'Which of the following is used to build mobile apps in Flutter?',
'options': ['Widgets', 'Components', 'Views', 'None of the above'],
'correctAnswer': 0,
},
];
}

void _answerQuestion(int selectedOption) {
if (selectedOption == questions[currentQuestionIndex]['correctAnswer']) {
score += 2; // Each correct answer gives 2 marks
}
_nextQuestion();
}

@override
Widget build(BuildContext context) {
if (quizCompleted) {
return Scaffold(
appBar: AppBar(
title: Text('Quiz Completed'),
backgroundColor: Colors.blueAccent,
elevation: 0,
),
body: Center(
child: Padding(
padding: const EdgeInsets.all(20.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text('Your Score: $score',
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
color: Colors.blueAccent)),
SizedBox(height: 20),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Color.fromARGB(255, 163, 190, 236),
padding:
EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
textStyle: TextStyle(fontSize: 18),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12.0),
),
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
CertificateScreen(score: score)),
);
},
child: Text('View Certificate',
style: TextStyle(color: Colors.white)),
),
],
),
),
),
);
}

return Scaffold(
appBar: AppBar(
title: Text('Quiz - ${widget.quizId}'),
backgroundColor: Colors.blueAccent,
elevation: 0,
),
body: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Time Left: $timeLeft sec',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.normal,
color: Colors.red),
),
SizedBox(height: 30), // Add space between timer and question
Text(
questions[currentQuestionIndex]['question'],
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.normal,
color: Colors.black87),
textAlign: TextAlign.center,
),
SizedBox(height: 30), // Add space between question and options
...List.generate(questions[currentQuestionIndex]['options'].length,
(index) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: TextButton(
onPressed: () => _answerQuestion(index),
style: TextButton.styleFrom(
padding: EdgeInsets.symmetric(vertical: 15.0),
textStyle:
TextStyle(fontSize: 16, color: Colors.blueAccent),
),
child:
Text(questions[currentQuestionIndex]['options'][index]),
),
);
}),
SizedBox(height: 20), // Space before the progress bar
LinearProgressIndicator(
value: (currentQuestionIndex + 1) / questions.length,
backgroundColor: Colors.grey[300],
valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
minHeight: 8,
),
],
),
),
);
}
}