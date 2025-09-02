import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffB9D2E3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          minimumSize: Size(38, 38),
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
                      // wait until its done
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
