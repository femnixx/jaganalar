import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jaganalar/Settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'SignIn.dart';
import 'Dashboard.dart';
import 'History.dart';
import 'Activity.dart';
import 'UserModel.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void logout() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        await SupabaseService.client.auth.signOut();
        print("Signed out successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Signin()),
        );
      } catch (error) {
        print(error);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 3;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CircleAvatar(radius: 52.5),
            SizedBox(height: 14),
            Text(
              'GANTI FOTO PROFIL',
              style: TextStyle(
                color: Color(0xff1C6EA4),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama lengkap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hint: Text('raion'),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nomor Telepon',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hint: Text('08232328931'),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hint: Text('raion@gmail.com '),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffD7D7D7),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Simpan Perubahan',
                        style: TextStyle(color: Color(0xff717171)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                MaterialPageRoute(builder: (_) => Editprofile()),
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
