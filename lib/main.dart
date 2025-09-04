import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jaganalar/main_screen.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gbpthsapjvxdmflikfkf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdicHRoc2FwanZ4ZG1mbGlrZmtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1Mzc4MjksImV4cCI6MjA3MjExMzgyOX0.UEO6Alzf0l9Ylytrr9uWqxOdoY48B-7pLZfeWTl-Dqg',
  );
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    print('Auth state changed: $data');
  });
  const String GEMINI_API_KEY = "AIzaSyAdP9SH8iyyGvPXa-zMUUEX4HCRZWUfFhU";

  await Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JagaNalar',
      theme: ThemeData(
        dialogBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white70,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final session = snapshot.data?.session;
            if (session == null || session.user == null) {
              return const Signin();
            } else {
              return MyMainScreen();
            }
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
