import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<String?> getUsername(BuildContext context) async {
    final user = SupabaseService.client.auth.currentUser;

    if (user == null) {
      // Redirect to sign in if no session
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Signin()),
        );
      });
      return null;
    }

    final response = await SupabaseService.client
        .from('users')
        .select('username')
        .eq('uuid', user.id) // Make sure 'uuid' column matches auth user id
        .single();

    return response['username'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: getUsername(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user found'));
          }

          final username = snapshot.data!;
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
                              Text('Selamat pagi, $username'),
                              const Text('Level 5 * 1250 xp'),
                            ],
                          ),
                        ],
                      ),
                      Center(child: Icon(Icons.notifications)),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 0.5,
                  ),
                  SizedBox(height: 20),
                  // level indicator
                  Column(
                    children: [
                      // Level and XP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level 5'),
                          Text('250/500 XP menuju Level 6')
                        ],
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.blueGrey[400],
                        color: Colors.black,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
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
                                child: Text('Mulai Misi')
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
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
                                    child: Text('View All')
                                  )
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Ranking 12'),
                                      Text('1,280 points this week')
                                    ],
                                  )
                                ],
                              )
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
                                  Text('Missions')
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
                                  Text('Medals')
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
                                  Text('Streak')
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
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
        selectedLabelStyle: TextStyle(
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
        ),
        currentIndex: 0,
        onTap: (index) {
          // handle tab change
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
                ),
            label: 'Home'
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.games,
    
            ),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
                ),
            label: 'History'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_2,
                ),
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
