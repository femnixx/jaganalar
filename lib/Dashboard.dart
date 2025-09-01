import 'package:flutter/material.dart';
import 'package:jaganalar/Activity.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Profile.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserModel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  int xpForLevel(int level) {
    // formula
    return 100 + (level - 1) * 50;
  }

  Future<UserModel?> fetchUser(String userId) async {
    // inside widget
    final response = await SupabaseService.client
        .from('users')
        .select('*') // select all columns you want
        .eq('uuid', userId)
        .single();

    if (response != null) {
      return UserModel.fromMap(response);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String userId;
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: fetchUser(Supabase.instance.client.auth.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user found'));
          }

          final user = snapshot.data!;

          // ensure level and xp are not null
          final int currentLevel = user.level ?? 1;
          final int currentXP = user.level ?? 0;

          // xp for current and next level
          int xpStart = xpForLevel(currentLevel);
          int xpNext = xpForLevel(currentXP + 1);

          // calculate progress fraction (0.0 - 1.0)
          double progress = (currentXP - xpStart) / (xpNext - xpStart);
          if (progress < 0) progress = 0.0;
          if (progress > 1) progress = 1.0;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Text('Selamat pagi, ${user.username}'),
                              Text('Level ${user.level} * ${user.xp} xp'),
                            ],
                          ),
                        ],
                      ),
                      Center(child: Icon(Icons.notifications)),
                    ],
                  ),
                  Divider(color: Colors.black, thickness: 0.5),
                  SizedBox(height: 20),
                  // level indicator
                  Column(
                    children: [
                      // Level and XP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level ${user.level}'),
                          Text(
                            '${user.xp}/100 XP menuju Level ${user.level! + 1}',
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.blueGrey[400],
                        color: Colors.black,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('Misi Mingguan'),
                              SizedBox(height: 16),
                              Text('Pendeteksi misinformasi digital'),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // implement logic to re direct to mission page
                                },
                                child: Text('Mulai Misi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ranking
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Ranking kamu'),
                                  SizedBox(width: 15),
                                  TextButton(
                                    onPressed: () {
                                      // Implement view logic if possible
                                    },
                                    child: Text('View All'),
                                  ),
                                ],
                              ),
                              // The actual ranking like number and how many points you have
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('#12'),
                                    ),
                                  ),
                                  // The ranking like ranking 12, how many points this week
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Ranking 12'),
                                      Text('1,280 points this week'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Badges, medals, and streak
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 50),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.sports_golf_rounded),
                                  Text('15'),
                                  Text('Missions'),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 50),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.sports_golf_rounded),
                                  Text('8'),
                                  Text('Medals'),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 50),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.sports_golf_rounded),
                                  Text('12'),
                                  Text('Streak'),
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
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        onTap: (index) {
          // handle tab change
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
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
