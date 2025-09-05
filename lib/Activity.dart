import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaganalar/DailyMissionsContent.dart';
import 'package:jaganalar/DailyMissionsQuiz.dart';
import 'package:jaganalar/Supabase.dart';
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
      const HistoryPage(),
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
    final userId = SupabaseService.client.auth.currentUser!.id;
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
          WeeklyMissionsContent(userId: userId),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: SupabaseService.client
                .from('questions')
                .select('*')
                .eq('is_daily', true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No daily missions available"));
              }

              final mission = snapshot.data!.first;

              // decode questions
              List<String> questions = [];
              final rawQuestions = mission['questions'];
              if (rawQuestions is String) {
                questions = List<String>.from(jsonDecode(rawQuestions));
              } else if (rawQuestions is List) {
                questions = List<String>.from(rawQuestions);
              }

              // Pass the mission to your DailyMissionsQuiz
              return DailyMissionsContent();
            },
          ),
        ],
      ),

      // bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
