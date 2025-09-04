import 'package:flutter/material.dart';
import 'package:jaganalar/DailyMissionsContent.dart';
import 'package:jaganalar/WeeklyMissionsContent.dart';
import 'Dashboard.dart';
import 'History.dart';
import 'Profile.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
    int _currentIndex = 1;

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
        Navigator.pushReplacement(
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff1C6EA4),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xff1C6EA4), width: 2.0),
            insets: EdgeInsets.symmetric(horizontal: 50.0),
          ),
          tabs: const [
            Tab(text: 'Misi Mingguan'),
            Tab(text: 'Misi Harian'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WeeklyMissionsContent(), // Moved to its own widget
          DailyMissionsContent(),
        ],
      ),
      // bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
