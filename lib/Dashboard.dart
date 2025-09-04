import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/Activity.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Profile.dart';
import 'package:jaganalar/QuizQuestion.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/UserModel.dart';
import 'package:jaganalar/main.dart';
import 'Supabase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

  // Reworked XP calculation logic to be more reusable and clear
  int xpForNextLevel(int level) => 100 + (level - 1) * 20;

  Future<void> updateLevel() async {
    final user = await fetchUser(userId);
    if (user == null) return;

    int totalXP = user.xp ?? 0;
    int newLevel = 1;

    while (totalXP >= xpForNextLevel(newLevel)) {
      newLevel++;
    }
    newLevel--; // Because loop runs one extra time

    if (newLevel < 1) newLevel = 1; // Safety check

    if (newLevel != user.level) {
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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<UserModel?>(
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
              final progress = ((currentXP) / (xpNext - xpStart)).clamp(
                0.0,
                1.0,
              );

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(
                        context,
                        user,
                        shortenName,
                        currentLevel,
                        currentXP,
                      ),
                      SizedBox(height: 20),
                      _buildXPCard(progress, currentLevel, currentXP, xpNext),
                      _buildWeeklyMission(context),
                      SizedBox(height: 20),
                      _buildRankingCard(context),
                      SizedBox(height: 20),
                      _buildStats(user),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  /// Header Section with Blue Background & SVG
  Widget _buildHeader(
    BuildContext context,
    UserModel user,
    String name,
    int level,
    int xp,
  ) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: const BoxDecoration(color: Color(0xff1C6EA4)),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/maskgroup.svg',
              fit: BoxFit.cover,
              color: Color(0xff19F0FB),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -40), // moves upward to overlap
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'You\'re off to a great start!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level $level',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$xp XP/',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${xpForNextLevel(level)}XP Menuju Level ${level + 1} ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff969696),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.blueGrey[200],
                              color: Colors.black,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 20,
                        child: SvgPicture.asset('assets/Levelup.svg'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Stats Section
  Widget _buildStats(UserModel user) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatBox(
            "Streak",
            user.streak ?? 0,
            'assets/framestreak.svg',
            'assets/streak2.svg',
          ),
          const SizedBox(width: 15),
          _buildStatBox(
            "Missions",
            user.missions ?? 0,
            'assets/framemissions.svg',
            'assets/plolygon.svg',
          ),
          const SizedBox(width: 15),
          _buildStatBox(
            "Medals",
            user.streak ?? 0,
            'assets/framestreak.svg',
            'assets/medals2.svg',
          ),
        ],
      ),
    );
  }

  /// Reusable Stat Box
  Widget _buildStatBox(
    String label,
    int value,
    String backgroundSvg,
    String iconSvg,
  ) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(backgroundSvg, fit: BoxFit.cover),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconSvg),
                const SizedBox(height: 8),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
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

  Widget _buildWeeklyMission(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SvgPicture.asset(
                  'assets/frame1(1).svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xffFFB146),
                            Color(0xffFF8A00),
                            Color(0xffFFA831),
                          ],
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3,
                        ),
                        child: Text(
                          'Misi Mingguan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Pendeteksi\nMisinformasi Digital',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final questions = await fetchQuizSets();
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
                              MaterialPageRoute(builder: (_) => Activity()),
                            ).then(
                              (_) => setState(
                                () => userFuture = fetchUser(userId),
                              ),
                            );
                          },
                          child: const Text(
                            'Mulai Misi >>',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SvgPicture.asset(
                  'assets/frame(2).svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xffFFB146),
                            Color(0xffFF8A00),
                            Color(0xffFFA831),
                          ],
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3,
                        ),
                        child: Text(
                          'Ranking Kamu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#12',
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '1,000 poin di minggu ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xffD7D7D7),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final questions = await fetchQuizSets();
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
                              MaterialPageRoute(builder: (_) => Activity()),
                            ).then(
                              (_) => setState(
                                () => userFuture = fetchUser(userId),
                              ),
                            );
                          },
                          child: const Text(
                            'Mulai Misi >>',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Navigation Bar
  // Place this method inside a State class, e.g., _MyScreenState
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex, // Now uses the state variable
      selectedItemColor: Color(0xff1C6EA4),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Correctly updates the state
        });
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
