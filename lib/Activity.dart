import 'package:flutter/material.dart';
import 'package:jaganalar/WeeklyMissionsContent.dart'; // We'll fix this next

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          const Center(child: Text('Content for Misi Harian')),
        ],
      ),
    );
  }
}
