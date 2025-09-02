import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/Supabase.dart';
import 'dart:async';
import 'Getstarted.dart';
import 'package:jaganalar/SignIn.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final user = SupabaseService.client.auth.currentSession;

  final List<Widget> _pages = [
    // first page - background
    SvgPicture.asset(
      'assets/copypaste.svg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),

    // second page - with logo
    Stack(
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/copypaste.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SvgPicture.asset(
                'assets/filledlogo.svg',
                width: 150,
                height: 150,
              ),
            ),
          ],
        ),
      ],
    ),
    // Third page - different logo
    Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset('assets/copypaste.svg', fit: BoxFit.cover),
        ),
        Center(
          child: SvgPicture.asset(
            'assets/emptylogo.svg',
            width: 150,
            height: 150,
          ),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // auto advance every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentPage < _pages.length - 1) {
        setState(() {
          _currentPage++;
        });
      } else {
        timer.cancel();
        // nav to main page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                user != null ? Dashboard() : OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentPage],
      ),
    );
  }
}
