import 'package:flutter/material.dart';
import 'package:jaganalar/Activity.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Profile.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final String userId = SupabaseService.client.auth.currentUser!.id;

  late Future<UserModel?> userFuture;

  Future<void> updateMissionCount() async {
    final user = await fetchUser(userId);
    int _addMissions = (user!.missions ?? 0) + 1;

    final response = await SupabaseService.client
        .from('users')
        .update({'missions': _addMissions})
        .eq('uuid', userId)
        .select();
    if (response != null) {
      print('Successfully updated missions.');
    }
    setState(() {
      userFuture = fetchUser(userId);
    });
  }

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(userId);
  }

  int xpForNextLevel(int level) {
    return 100 + (level - 1) * 20;
  }

  Future<int> computeLevel(int totalXP) async {
    int level = 1;
    int xpNeeded = xpForNextLevel(level);

    while (totalXP >= xpNeeded) {
      totalXP -= xpNeeded;
      level++;
      xpNeeded = xpForNextLevel(level);
    }
    return level;
  }

  Future<void> nextLevel() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int currentLevel = user.level ?? 0;
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
          .update({'level': newLevel, 'xp': totalXP})
          .eq('uuid', userId)
          .select();
    }

    setState(() {
      userFuture = fetchUser(userId);
    });
  }

  Future<UserModel?> fetchUser(String userId) async {
    final response = await SupabaseService.client
        .from('users')
        .select('*')
        .eq('uuid', userId)
        .single();

    if (response != null) {
      return UserModel.fromMap(response);
    }
    return null;
  }

  Future<void> gainXP() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int newXP = (user.xp ?? 0) + 20;

    await SupabaseService.client
        .from('users')
        .update({'xp': newXP})
        .eq('uuid', userId)
        .select();

    await nextLevel();

    setState(() {
      userFuture = fetchUser(userId);
    });
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
            return const Center(child: Text('No user found'));
          }

          final user = snapshot.data!;
          final int currentLevel = user.level ?? 0;
          final int currentXP = user.xp ?? 0;

          int xpForPreviousLevels(int level) {
            int total = 0;
            for (int i = 1; i < level; i++) {
              total += xpForNextLevel(i);
            }
            return total;
          }

          int xpStart = xpForPreviousLevels(currentLevel);
          int xpNext = xpStart + xpForNextLevel(currentLevel);
          double progress = (currentXP - xpStart) / (xpNext - xpStart);
          progress = progress.clamp(0.0, 1.0);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selamat pagi, ${user.username}'),
                              Text('Level ${user.level} * ${user.xp} xp'),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.notifications),
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 0.5),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level ${user.level}'),
                          Text(
                            '${currentXP}/$xpNext XP menuju Level ${user.level! + 1}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.blueGrey[400],
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Misi Mingguan'),
                              const SizedBox(height: 16),
                              const Text('Pendeteksi misinformasi digital'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  await gainXP();
                                  await updateMissionCount();
                                },
                                child: const Text('Mulai Misi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Ranking kamu'),
                                  SizedBox(width: 15),
                                  Text('View All'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                10,
                                15,
                                50,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.sports_golf_rounded),
                                  Text('${user.missions}'),
                                  const Text('Missions'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                10,
                                15,
                                50,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.sports_golf_rounded),
                                  Text('${user.medals}'),
                                  const Text('Medals'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                10,
                                15,
                                50,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.sports_golf_rounded),
                                  Text('${user.streak}'),
                                  const Text('Streak'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Dashboard()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Activity()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => History()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
              break;
          }
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
