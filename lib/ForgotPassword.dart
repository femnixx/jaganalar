import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // timer
  int _seconds = 60;
  Timer? _timer;

  void _startCountdown() {
    _timer?.cancel();

    setState(() {
      _seconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updatePassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmpassword = confirmPasswordController.text;

    final UserResponse res = await SupabaseService.client.auth.updateUser(
      UserAttributes(password: password),
    );
    final User? updatedUser = res.user;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Signin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid =
        emailController.text.isNotEmpty && emailController.text != '';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Title(
          color: Colors.black,
          child: Text(
            'Lupa Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  Text(
                    'Masukkan email anda untuk proses verifikasi. Kami akan mengirimkan kode tautan khusus ke email anda unntuk mengatur ulang password.',
                    style: TextStyle(
                      color: Color(0xff71717A),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (text) => {setState(() {})},
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xffDBDCDC)),
                      ),
                      hint: Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xff8B8F90),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    // implement logic
                  },
                  child: Text(
                    'Belum menerima email?',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  isValid ? Color(0xff1C6EA4) : Color(0xffD7D7D7),
                ),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
              ),
              onPressed: () {},
              child: Text(
                'Kirim',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isValid ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
