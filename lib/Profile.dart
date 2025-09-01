import 'package:flutter/material.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase/supabase.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: SafeArea(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
