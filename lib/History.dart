import 'package:flutter/material.dart';
import 'Dashboard.dart';
import 'Activity.dart';
import 'Profile.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Widget _buildBottomNav(BuildContext context) {
    int _currentIndex = 2;

    final pages = [
      const Dashboard(),
      const Activity(),
      const History(),
      const Profile(),
    ];
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Color(0xff1C6EA4),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _currentIndex = index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pages[index]),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Click me to go back'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
