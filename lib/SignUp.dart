import 'dart:js_interop';

import 'package:flutter/material.dart';
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
        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        final Session? session = res.session;
        final User? user = res.user;
      } catch (error) {
        print(error);
      }
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [

        ],
      ));
  }
}
