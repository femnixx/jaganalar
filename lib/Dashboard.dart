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

  Future<void> nextLevel() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int currentLevel = user.level ?? 1;
    int totalXP = user.xp ?? 0;
    int newLevel = 1;
    int remainingXP = totalXP;

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

    setState(() {
      userFuture = fetchUser(userId);
    });
  }

  Future<void> gainXP() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int newXP = (user.xp ?? 0) + 20;
    await SupabaseService.client
        .from('users')
        .update({'xp': newXP})
        .eq('uuid', userId);

    await nextLevel();
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

          if (!snapshot.hasData || snapshot.data == null) {
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

          final user = snapshot.data!;
          final currentLevel = user.level ?? 1;
          final currentXP = user.xp ?? 0;
          final username = user.username ?? "User";
          final shortenName = username.length > 5
              ? '${username.substring(0, 5)}...'
              : username;

          // XP progress calculation
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
                // Top Section with Blue Background + SVG
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: double.infinity,
                  color: const Color(0xff1C6EA4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        // SVG as decorative overlay
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/maskgroup.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Top content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Avatar + Greeting
                            Row(
                              children: [
                                const CircleAvatar(),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Selamat Pagi, $shortenName 👋',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Level $currentLevel • $currentXP XP',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Notifications
                            InkWell(
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // XP Progress
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Hi there'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level $currentLevel'),
                          Text(
                            '$currentXP / $xpNext XP menuju Level ${currentLevel + 1}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.blueGrey[400],
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),

                // Weekly Mission
                Container(
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
                              const SnackBar(
                                content: Text("No quiz questions available."),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(questions: questions),
                            ),
                          ).then((_) {
                            setState(() {
                              userFuture = fetchUser(userId);
                            });
                          });
                        },
                        child: const Text('Mulai Misi'),
                      ),
                    ],
                  ),
                ),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox("Missions", user.missions ?? 0),
                      _buildStatBox("Medals", user.medals ?? 0),
                      _buildStatBox("Streak", user.streak ?? 0),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          final pages = [Dashboard(), Activity(), History(), Profile()];
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
      ),
    );
  }

  // Helper widget for stats
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
}
