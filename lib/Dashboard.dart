import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/Activity.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Profile.dart';
import 'package:jaganalar/QuizQuestion.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final String userId = SupabaseService.client.auth.currentUser!.id;
  late Future<UserModel?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(userId);
  }

  Future<UserModel?> fetchUser(String userId) async {
    final response = await SupabaseService.client
        .from('users')
        .select('*')
        .eq('uuid', userId)
        .single();
    return response != null ? UserModel.fromMap(response) : null;
  }

  int xpForNextLevel(int level) => 100 + (level - 1) * 20;

  Future<void> updateLevel() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int currentLevel = user.level ?? 1;
    int totalXP = user.xp ?? 0;
    int newLevel = 1, remainingXP = totalXP;

    while (remainingXP >= xpForNextLevel(newLevel)) {
      remainingXP -= xpForNextLevel(newLevel);
      newLevel++;
    }

    if (newLevel != currentLevel) {
      await SupabaseService.client
          .from('users')
          .update({'level': newLevel})
          .eq('uuid', userId);
    }

    setState(() => userFuture = fetchUser(userId));
  }

  Future<void> gainXP() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    await SupabaseService.client
        .from('users')
        .update({'xp': (user.xp ?? 0) + 20})
        .eq('uuid', userId);

    await updateLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return _buildNoUserFound(context);
          }

          final user = snapshot.data!;
          final currentLevel = user.level ?? 1;
          final currentXP = user.xp ?? 0;
          final username = user.username ?? "User";
          final shortenName = username.length > 5
              ? '${username.substring(0, 5)}...'
              : username;

          // XP Progress Calculation
          int xpForPreviousLevels(int level) {
            int total = 0;
            for (int i = 1; i < level; i++) {
              total += xpForNextLevel(i);
            }
            return total;
          }

          final xpStart = xpForPreviousLevels(currentLevel);
          final xpNext = xpStart + xpForNextLevel(currentLevel);
          final progress = ((currentXP - xpStart) / (xpNext - xpStart)).clamp(
            0.0,
            1.0,
          );

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, shortenName, currentLevel, currentXP),
                _buildXPCard(progress, currentLevel, currentXP, xpNext),
                _buildWeeklyMission(context),
                _buildStats(user),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Header Section with Blue Background & SVG
  Widget _buildHeader(BuildContext context, String name, int level, int xp) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.20,
      decoration: const BoxDecoration(color: Color(0xff1C6EA4)),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset('assets/maskgroup.svg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Pagi, $name 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Level $level • $xp XP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildNotificationButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Overlapping XP Progress Card
  Widget _buildXPCard(double progress, int level, int xp, int xpNext) {
    return Transform.translate(
      offset: const Offset(0, -40), // moves upward to overlap
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5),
            ],
          ),
          child: Column(
            children: [
              const Text('You\'re off to a great start!'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Level $level'), Text('$xp XP / $xpNext XP')],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blueGrey[200],
                color: Colors.black,
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Weekly Mission Section
  Widget _buildWeeklyMission(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          const Text('Misi Mingguan'),
          const SizedBox(height: 16),
          const Text('Pendeteksi misinformasi digital'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final questions = await fetchQuizQuestions();
              if (questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No quiz questions available.")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizPage(questions: questions),
                ),
              ).then((_) => setState(() => userFuture = fetchUser(userId)));
            },
            child: const Text('Mulai Misi'),
          ),
        ],
      ),
    );
  }

  /// Stats Section
  Widget _buildStats(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatBox("Missions", user.missions ?? 0),
          _buildStatBox("Medals", user.medals ?? 0),
          _buildStatBox("Streak", user.streak ?? 0),
        ],
      ),
    );
  }

  /// Reusable Stat Box
  Widget _buildStatBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          const Icon(Icons.sports_golf_rounded),
          Text('$value'),
          Text(label),
        ],
      ),
    );
  }

  /// Notification Button
  Widget _buildNotificationButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xffB9D2E3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.notifications,
          color: Color(0xff1C6EA4),
          size: 20,
        ),
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
    final pages = [
      const Dashboard(),
      const Activity(),
      const History(),
      const Profile(),
    ];
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Colors.black,
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

  /// Fallback if no user found
  Widget _buildNoUserFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No user found'),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Signin()),
            ),
            child: const Text('Return to Sign In'),
          ),
        ],
      ),
    );
  }
}
