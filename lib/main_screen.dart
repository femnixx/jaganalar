import 'package:flutter/material.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/Activity.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Profile.dart';

class MyMainScreen extends StatefulWidget {
  const MyMainScreen({super.key});

  @override
  State<MyMainScreen> createState() => _MyMainScreenState();
}

class _MyMainScreenState extends State<MyMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(visible: _currentIndex == 0, child: const Dashboard()),
          Visibility(visible: _currentIndex == 1, child: const Activity()),
          Visibility(visible: _currentIndex == 2, child: const History()),
          Visibility(visible: _currentIndex == 3, child: const Profile()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff1C6EA4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
        ],
      ),
    );
  }
}
