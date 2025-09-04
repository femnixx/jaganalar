import 'Dashboard.dart';
import 'Activity.dart';
import 'package:flutter/material.dart';
import 'History.dart';
import 'Profile.dart';

// Your main screen should be a StatefulWidget to manage the tab state
class MyMainScreen extends StatefulWidget {
  const MyMainScreen({super.key});

  @override
  State<MyMainScreen> createState() => _MyMainScreenState();
}

class _MyMainScreenState extends State<MyMainScreen> {
  // 1. Move _currentIndex and pages to the state class
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const Activity(),
    const History(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. The body of the Scaffold changes based on the index
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff1C6EA4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // 3. Update the state and rebuild the UI
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
