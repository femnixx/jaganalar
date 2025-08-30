import 'package:flutter/material.dart';
import 'package:jaganalar/SignIn.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  

  @override
  Widget build(BuildContext context) {
  Future <String?> getUsername() async { 
    final user = SupabaseService.client.auth.currentSession;
    if (user == null) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => Signin())
      );
    } 

  // final response = await Supabase.instance.client
  //   .from('users')
  //   .select('username')
  //   .eq('id', Supabase.inst)
  } 

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            CircleAvatar(),
            Column(
              children: [
                Text('Selamat pagi, Nana'),
                Text('Hi there')
              ],
            )
          ],
        ) 
      )
    );
  }
}