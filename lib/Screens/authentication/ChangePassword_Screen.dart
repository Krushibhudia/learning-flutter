import 'package:flutter/material.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart'; // Import ConstantsText
import 'package:flutterpro/Custom_Widgets/CustomTextField.dart'; // Import CustomTextField
import 'package:flutterpro/Custom_Widgets/GradientButton.dart'; // Import GradientButton
import '../../Utils/Validations.dart'; // Import Validation class

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Password and Confirm Password
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _password = '';
  String _confirmPassword = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Add logic to change password
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')));
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(ConstantsText.ChangePassword),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Password Input Field with Controller
              CustomTextField(
                hintText: ConstantsText.Password,
                icon: Icons.lock,
                obscureText: _obscurePassword,
              maxLines: 1,
                keyboardType: TextInputType.text,
                controller: _passwordController, // Pass controller here
                onSaved: (value) => _password = value ?? '',
                validator: (value) => Validation.validatePassword(value),
                toggleVisibility: _togglePasswordVisibility,
              ),
              const SizedBox(height: 20),

              // Confirm Password Input Field with Controller
              CustomTextField(
                hintText: ConstantsText.ConfirmPassword,
                icon: Icons.lock,
                maxLines: 1,
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.text,
                controller: _confirmPasswordController, // Pass controller here
                onSaved: (value) => _confirmPassword = value ?? '',
                validator: (value) =>
                    Validation.validateConfirmPassword(_password, value),
                toggleVisibility: _toggleConfirmPasswordVisibility,
              ),
              const SizedBox(height: 30),

              // Submit Button
              GradientButton(
                buttonText: ConstantsText.ChangePassword,
                onPressed: _onSubmit,
                gradientColors: [
                  Colors.blueAccent.shade700,
                  Colors.blue.shade500,
                  Colors.lightBlueAccent.shade200,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
