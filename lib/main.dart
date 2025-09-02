import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/ForgotPassword2.dart';
import 'package:jaganalar/Getstarted.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/SignUp.dart';
import 'package:jaganalar/Splashscreen.dart';
import 'package:jaganalar/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'consts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important!

  await Gemini.init(apiKey: GEMINI_API_KEY);

  await Supabase.initialize(
    url: 'https://gbpthsapjvxdmflikfkf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicHRoc2FwanZ4ZG1mbGlrZmtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1Mzc4MjksImV4cCI6MjA3MjExMzgyOX0.UEO6Alzf0l9Ylytrr9uWqxOdoY48B-7pLZfeWTl-Dqg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: session != null ? Splashscreen() : Splashscreen(),
    );
  }
}
