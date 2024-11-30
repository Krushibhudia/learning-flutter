import 'package:flutter/material.dart';

class CertificateScreen extends StatelessWidget {
  final int score;

  const CertificateScreen({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Certificate'),
        backgroundColor:
        Colors.blueAccent, // Consistent color with previous screens
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                score > 20
                    ? 'Congratulations!'
                    : 'Oops, better luck next time!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Matching color with other screens
                ),
              ),
              SizedBox(height: 20),
              Text(
                'You scored $score out of 30!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: score > 20
                    ? () {
                  // Logic to download or show certificate
                }
                    : null, // Disable button if score is <= 20
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.blueAccent, // Same as app bar and other buttons
                  padding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                  textStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15.0), // Rounded corners for modern look
                  ),
                  elevation: 5, // Button shadow for depth
                ),
                child: Text(
                  'Download Certificate',
                  style: TextStyle(
                      color: Colors.white), // White text on blue button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}