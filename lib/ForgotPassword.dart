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
    final bool isValid =
        emailController.text.isNotEmpty && emailController.text != '';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Title(color: Colors.black, child: Text('Lupa Password')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: TextField(
                onChanged: (text) => {setState(() {})},
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffDBDCDC)),
                  ),
                  hint: Text(
                    'Email',
                    style: TextStyle(color: Color(0xff8B8F90)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Masukkan email anda untuk proses verifikasi, kami akann nmengirimkan kode 5 digit ke email anda',
              style: TextStyle(
                color: Color(0xff71717A),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 42),
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
                  fontSize: 14,
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
