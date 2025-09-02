import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaganalar/Settings.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase/supabase.dart';
import 'History.dart';
import 'Dashboard.dart';
import 'EditProfile.dart';
import 'Activity.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 3;
  final String userId = SupabaseService.client.auth.currentUser!.id;
  late Future<UserModel?> userFuture;

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

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(userId);
  }

  int xpForNextLevel(int level) {
    return 100 + (level - 1) * 20;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error or no user data found'));
          }

          final user = snapshot.data!;
          final int currentXP = user.xp ?? 0;
          final int currentLevel = user.level ?? 0;
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 11,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // navigate to settings
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Settings()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          padding: EdgeInsets.zero,
                          backgroundColor: Color(0xffB9D2E3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          fixedSize: Size(38, 38),
                        ),
                        child: Icon(Icons.settings, color: Color(0xff1C6EA4)),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff1C6EA4),
                          border: Border.all(
                            color: Color(0xff1C6EA4),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(radius: 52.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    '${user.username}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Level ${user.level} - Ahli Empati',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff969696),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20),
                  // The problematic Expanded widget has been removed.
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/premium.svg',
                        width: MediaQuery.of(context).size.width * 1,
                      ),
                      Align(
                        child: Row(
                          // Use a Row to arrange children horizontally
                          mainAxisAlignment: MainAxisAlignment
                              .spaceAround, // Distributes children with space between them
                          children: [
                            Column(
                              // The text is on the left
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time to Level Up,',
                                  style: TextStyle(
                                    color: Color(0xff0F3D5A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Let\'s go Premium Now',
                                  style: TextStyle(
                                    color: Color(0xff0F3D5A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff1C6EA4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(120, 50),
                              ),
                              // The button is on the right
                              onPressed: () {},
                              child: Text(
                                'Selengkapnya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: SvgPicture.asset(
                              'assets/emptylogo.svg',
                              width: 50,
                              height: 54,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${user.username}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffE2EBF0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 6,
                              ),
                              child: Text(
                                'Lv. ${user.level}',
                                style: TextStyle(
                                  color: Color(0xff1C6EA4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          SegmentedProgressBar(progress: progress, segments: 4),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Koleksi Lencana',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 13),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Make it work later on
                              Medals(unlocked: true),
                              Medals(unlocked: true),
                              Medals(unlocked: false),
                              Medals(unlocked: false),
                              Medals(unlocked: false),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                              backgroundColor: Color(0xff1C6EA4),
                            ),
                            onPressed: () {
                              // Lihat papan peringkat or whatever
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_outline, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Lihat Papan Peringkat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class SegmentedProgressBar extends StatelessWidget {
  final double progress; // between 0.0 and 1.0
  final int segments;

  const SegmentedProgressBar({
    super.key,
    required this.progress,
    this.segments = 1, // default 4 segments
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7,
      child: Stack(
        children: [
          // Background progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1C6EA4)),
            ),
          ),

          // Dividers
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                List<Widget> lines = [];
                for (int i = 1; i < segments; i++) {
                  double left = constraints.maxWidth * (i / segments);
                  lines.add(
                    Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2, // line thickness
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return Stack(children: lines);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Medals extends StatelessWidget {
  const Medals({super.key, required this.unlocked});
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final lockedPicture = SvgPicture.asset('assets/Badge_06.svg');
    final unlockedPicture = SvgPicture.asset('assets/uis_lock.svg');

    return Container(
      child: unlocked
          ? Row(children: [lockedPicture, SizedBox(width: 10)])
          : Row(children: [unlockedPicture, SizedBox(width: 10)]),
    );
  }
}
