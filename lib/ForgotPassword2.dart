import 'package:flutter/material.dart';
import 'package:jaganalar/ForgotPassword.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Forgotpassword2 extends StatefulWidget {
  const Forgotpassword2({super.key});

  @override
  State<Forgotpassword2> createState() => _Forgotpassword2State();
}

class _Forgotpassword2State extends State<Forgotpassword2> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // A boolean to toggle password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_updateButtonState);
    confirmPasswordController.addListener(_updateButtonState);
    setState(() {
      _updateButtonState();
    });
  }

  @override
  void dispose() {
    passwordController.removeListener(_updateButtonState);
    confirmPasswordController.removeListener(_updateButtonState);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void _updateButtonState() {
    setState(() {
      _isPasswordValid =
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      ); // This makes the back button functional
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Expanded(
                    child: Text(
                      'Lupa Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible, // Toggles visibility
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible =
                            !_isPasswordVisible; // Correct state change
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible, // Toggles visibility
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Konfirmasi Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible; // Correct state change
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPasswordValid
                      ? Color(0xff1C6EA4)
                      : Color(0xffD7D7D7),
                ),
                onPressed: _isPasswordValid
                    ? () {
                        // implement logic here
                      }
                    : null,
                child: Text(
                  'Ubah Password',
                  style: TextStyle(
                    color: _isPasswordValid ? Colors.white : Color(0xff717171),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
