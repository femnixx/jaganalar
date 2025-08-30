import 'package:flutter/material.dart';
import 'package:jaganalar/home_page.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signin extends StatefulWidget {
  Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signin() async {
    String email = emailController.text;
    String password = passwordController.text;

    final AuthResponse res = await SupabaseService.client.auth
        .signInWithPassword(email: email, password: password);
    final Session? session = res.session;
    final User? user = res.user;
    dispose();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Container(
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(label: Text('Email')),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(label: Text('Password')),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: signin, child: Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
