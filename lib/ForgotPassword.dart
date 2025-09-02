import 'package:flutter/material.dart';
import 'package:jaganalar/Supabase.dart';
import 'dart:async';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  int _seconds = 60;
  Timer? _timer;
  bool _isButtonDisabled = false;

  void _startCountdown() {
    _timer?.cancel();

    setState(() {
      _seconds = 60;
      _isButtonDisabled = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  void updatePassword() async {
    final String email = emailController.text;

    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link reset password telah dikirim")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = emailController.text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header Row
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
                  const SizedBox(width: 48), // keeps title centered
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Masukkan email anda untuk proses verifikasi. Kami akan mengirimkan '
                'tautan khusus ke email anda untuk mengatur ulang password.',
                style: TextStyle(color: Color(0xff71717A), fontSize: 16),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 12),

              TextField(
                onChanged: (_) => setState(() {}),
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffDBDCDC)),
                  ),
                  hintText: 'Email',
                  hintStyle: const TextStyle(
                    color: Color(0xff8B8F90),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: !_isButtonDisabled ? _startCountdown : null,
                        child: const Text(
                          'Belum menerima email?',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      if (_seconds > 0 && _isButtonDisabled)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text("Kirim ulang dalam 00:$_seconds"),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid && !_isButtonDisabled
                      ? const Color(0xff1C6EA4)
                      : const Color(0xffD7D7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shadowColor: Colors.transparent,
                ),
                onPressed: (isValid && !_isButtonDisabled)
                    ? () {
                        _startCountdown();
                        updatePassword();
                      }
                    : null,
                child: Text(
                  'Kirim',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isValid && !_isButtonDisabled
                        ? Colors.white
                        : Colors.grey,
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
