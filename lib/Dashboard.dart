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
                      Text('hji')
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
