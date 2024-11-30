import 'package:flutterpro/Constants/Constants+Images.dart';
import 'package:flutter/material.dart';
import 'package:flutterpro/Constants/Constants+Texts.dart'; // Import ConstantsText
import 'package:flutterpro/Custom_Widgets/CustomTextField.dart'; // Import CustomTextField
import 'package:flutterpro/Custom_Widgets/GradientButton.dart'; // Import GradientButton

import '../../Utils/Validations.dart'; // Import Validation class

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  // Form field controllers (optional for managing text input)
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Validate and Save Profile Data
  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // Proceed with the profile save logic (e.g., update user profile)
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text(ConstantsText.EditProfile), // Using constant for title
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard appears
      body: SingleChildScrollView(
        // Make content scrollable
        child: Container(
          width: size.width,
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Form(
            key: _formKey, // Assign the form key here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.15, // Profile picture size
                        backgroundImage: const AssetImage(
                            Constants.logo), // Placeholder image
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            // Logic to change profile picture
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: size.width * 0.05, // Edit icon size
                            child: Icon(Icons.edit,
                                color: Colors.white, size: size.width * 0.04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height:
                        size.height * 0.03), // Spacing after profile picture

                // Full Name Input Field with Validation
                CustomTextField(
                  hintText: ConstantsText.FullName, // Using constant
                  icon: Icons.person,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  controller: _fullNameController,
                  validator: (value) => Validation.validateFullName(value),
                ),
                const SizedBox(height: 20), // Spacing

                // Email Input Field with Validation
                CustomTextField(
                  hintText: ConstantsText.EmailID, // Using constant
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  maxLines: 1,
                  controller: _emailController,
                  validator: (value) => Validation.validateEmail(value),
                ),
                const SizedBox(height: 20), // Spacing

                // Phone Number Input Field with Validation
                CustomTextField(
                  hintText: ConstantsText.PhoneNumber, // Using constant
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  obscureText: false,
                  maxLines: 1,
                  controller: _phoneController,
                  validator: (value) {
                    // You can add custom validation for phone number
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null; // Add phone number validation logic
                  },
                ),
                const SizedBox(height: 20), // Spacing

                // Bio Input Field with Validation
                CustomTextField(
                  hintText: ConstantsText.Bio, // Using constant
                  icon: Icons.info_outline,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  maxLines: 1,
                  controller: _bioController,
                  validator: (value) =>
                      Validation.validateFullName(value), // Example validation
                ),
                const SizedBox(height: 20), // Spacing

                // Save Changes Button
                GradientButton(
                  buttonText: ConstantsText.SaveChanges, // Using constant
                  onPressed: _saveProfile, // Calls save profile logic
                  gradientColors: [
                    Colors.blueAccent.shade700,
                    Colors.blue.shade500,
                    Colors.lightBlueAccent.shade200,
                  ],
                ),
                const Spacer(), // Pushes content up
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
