import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart';
import 'package:flutterpro/FirebaseServices/AuthenticationManager.dart';
import 'package:flutterpro/Screens/InstructorPanel/mainPanel.dart';
import 'package:flutterpro/Screens/authentication/ForgotPassword_screen.dart';
import 'package:flutterpro/Screens/authentication/Register_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Utils/Validations.dart';
import '../../Custom_Widgets/CustomTextField.dart'; // Reusable TextField
import '../../Custom_Widgets/GradientButton.dart';
import '../InstructorPanel/InstructorDashBoard_Screen.dart';
import '../StudentPanel/mainHomeScreen.dart'; // Reusable Gradient Button
//import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        var user =
            await _authService.loginWithEmailAndPassword(email, password);
        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          String role = userDoc['role'] ?? 'student';
          await FirebaseFirestore.instance
              .collection('sessions')
              .doc(user.uid)
              .set({
            'email': user.email,
            'loginTime': Timestamp.now(),
            'isLoggedIn': true,
          });
          if (role == 'Instructor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainPanel()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Mainhomescreen()),
            );
          }
        }
      } catch (e) {
        // Handle errors (e.g., show Snackbar with error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Reusable method for Forgot Password TextButton
  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          ConstantsText.ForgotPassword,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            width: size.width,
            height: size.height,
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      Constants.logo,
                      height: 180,
                      width: 160,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    ConstantsText.LoginTitle,
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ConstantsText.LoginSubtitle,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  CustomTextField(
                    hintText: ConstantsText.EmailID,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    maxLines: 1,

                    controller: _emailController,
                    validator: Validation.validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    hintText: ConstantsText.Password,
                    icon: Icons.lock,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscure,
                    maxLines: 1,

                    controller: _passwordController,
                    validator: Validation.validatePassword,
                    toggleVisibility: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // Forgot Password Button
                  _buildForgotPasswordButton(context),

                  const SizedBox(height: 20),

                  // Login Button (Using GradientButton widget)
                  GradientButton(
                    buttonText: ConstantsText.Login,
                    onPressed: _handleLogin,
                    gradientColors: [
                      Colors.blueAccent.shade700,
                      Colors.blue.shade500,
                      Colors.lightBlueAccent.shade200,
                    ],
                  ),

                  const Spacer(),

                  // Register Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ConstantsText.DontHaveAccount,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ConstantsText.Register,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}