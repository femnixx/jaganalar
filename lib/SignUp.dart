import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // sign up
  void signUp() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;

    // supabase function
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      try {
        final AuthResponse res = await SupabaseService.client.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        await SupabaseService.client.from('users').insert({
          'username': username,
          'email': email,
          'timestamp': DateTime.now().toIso8601String(),
        });
        dispose();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Signin()),
        );
      } catch (error) {
        SnackBar(content: Text('Error: $error'));
        print(error);
      }
    }
  }

  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(6),
        child: Container(
          child: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(label: Text('Username')),
              ),
              SizedBox(height: 2.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(label: Text('Email')),
              ),
              SizedBox(height: 2.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(label: Text('Password')),
                obscureText: true,
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  signUp();
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
