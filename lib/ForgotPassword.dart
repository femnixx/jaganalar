import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Title(
          color: Colors.black, 
          child: Text('Lupa Password')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffDBDCDC))
                  ),
                  hint: Text(
                    'Email',
                    style: TextStyle(
                      color: Color(0xff8B8F90)
                    ),
                  )
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Masukkan email anda untuk proses verifikasi, kami akann nmengirimkan kode 5 digit ke email anda',
              style: TextStyle(
                color: Color(0xff71717A),
                fontWeight: FontWeight.normal
              ),
            )
          ],
        ),
      ),
    );
  }
}