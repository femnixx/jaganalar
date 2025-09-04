import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaganalar/Premium.dart';
import 'package:jaganalar/Settings.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase/supabase.dart';
import 'History.dart';
import 'Dashboard.dart';
import 'Activity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> uploadProfilePicture(String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final fileExt = p.extension(imageFile.path);
    final filePath = '$userId$fileExt';

    // upload to supabasestorage
    final uploadResponse = await SupabaseService.client.storage
        .from('avatars')
        .upload(filePath, imageFile);

    if (uploadResponse.isEmpty) {
      print('Upload error');
      return;
    }

    // get public URL
    final imageUrl = SupabaseService.client.storage
        .from('avatars')
        .getPublicUrl(filePath);

    await SupabaseService.client
        .from('users')
        .update({'avatar_url': imageUrl})
        .eq('uuid', userId);

    setState(() {});
  }

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
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
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
            double progress = (currentXP) / (xpNext - xpStart);
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Settings(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            backgroundColor: Color(0xffB9D2E3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                          child: GestureDetector(
                            child: CircleAvatar(
                              radius: 52.5,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            onTap: () async {
                              await uploadProfilePicture(userId);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      '${user.username}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/goldenmask.svg',
                          width: MediaQuery.of(context).size.width * 1,
                        ),
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saatnya Naik Level, Yuk Upgrade',
                                      style: TextStyle(
                                        color: Color(0xffBA2A42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'ke Premium Sekarang!',
                                      style: TextStyle(
                                        color: Color(0xffBA2A42),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Premium(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Lihat >>',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 15),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/medals2.svg',
                                    width: 70,
                                    height: 60,
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
                                SegmentedProgressBar(
                                  progress: progress,
                                  segments: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Koleksi Lencana',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 13),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Medals(unlocked: true),
                          Medals(unlocked: true),
                          Medals(unlocked: false),
                          Medals(unlocked: false),
                          Medals(unlocked: false),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Color(0xff1C6EA4),
                      ),
                      onPressed: () {
                        // Navigate to leaderboard
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
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
      //   type: BottomNavigationBarType.fixed,
      //   selectedLabelStyle: const TextStyle(fontSize: 14),
      //   unselectedLabelStyle: const TextStyle(fontSize: 14),
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //     switch (index) {
      //       case 0:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const Dashboard()),
      //         );
      //         break;
      //       case 1:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => Activity()),
      //         );
      //         break;
      //       case 2:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => History()),
      //         );
      //         break;
      //       case 3:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => Profile()),
      //         );
      //         break;
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Activity'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
      //   ],
      // ),
    );
  }
}

class SegmentedProgressBar extends StatelessWidget {
  final double progress;
  final int segments;

  const SegmentedProgressBar({
    super.key,
    required this.progress,
    this.segments = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1C6EA4)),
            ),
          ),
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
                      child: Container(width: 2, color: Colors.white),
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
    // Corrected the logic to show the right asset based on `unlocked`
    final SvgPicture medalPicture = unlocked
        ? SvgPicture.asset('assets/Badge_06.svg')
        : SvgPicture.asset('assets/uis_lock.svg');

    return Container(child: Row(children: [medalPicture, SizedBox(width: 10)]));
  }
}
