import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/Supabase.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Switch states
  bool receiveNotifications = true;
  bool weeklyMissions = false;
  bool dailyReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              Text(
                'Akun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              SettingsBuilder(
                items1: 'Preferensi',
                items2: 'Edit Profil',
                items3: 'Ganti Password',
              ),
              SizedBox(height: 20),

              // Notifications Section
              Text(
                'Notifikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              SettingsBuilder(
                items1: 'Terima Notifikasi',
                items2: 'Misi Mingguan Terbaru',
                items3: 'Pengingat Misi Harian',
                switch1: receiveNotifications,
                switch2: weeklyMissions,
                switch3: dailyReminders,
                onSwitch1Changed: (val) =>
                    setState(() => receiveNotifications = val),
                onSwitch2Changed: (val) => setState(() => weeklyMissions = val),
                onSwitch3Changed: (val) => setState(() => dailyReminders = val),
              ),
              SizedBox(height: 20),

              // Premium Section
              Text(
                'Langganan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text content
                    Column(
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
                    // Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff1C6EA4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(120, 50),
                      ),
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
              SizedBox(height: 20),

              // Others Section
              Text(
                'Lainnya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              SettingsBuilder(
                items1: 'Pusat Bantuan',
                items2: 'Kebijakan Privasi',
                items3: 'Ketentuan',
              ),
              SizedBox(height: 20),

              // Sign Out Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await SupabaseService.client.auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Signin()),
                    );
                  },
                  child: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsBuilder extends StatelessWidget {
  const SettingsBuilder({
    super.key,
    required this.items1,
    required this.items2,
    required this.items3,
    this.switch1,
    this.switch2,
    this.switch3,
    this.onSwitch1Changed,
    this.onSwitch2Changed,
    this.onSwitch3Changed,
  });

  final String items1, items2, items3;
  final bool? switch1, switch2, switch3;
  final ValueChanged<bool>? onSwitch1Changed;
  final ValueChanged<bool>? onSwitch2Changed;
  final ValueChanged<bool>? onSwitch3Changed;

  Widget _buildTile(
    String title,
    bool? switchValue,
    ValueChanged<bool>? onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: switchValue != null
          ? Switch(value: switchValue, onChanged: onChanged)
          : Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xff8F9799)),
      ),
      child: Column(
        children: [
          _buildTile(items1, switch1, onSwitch1Changed),
          Divider(indent: 16, endIndent: 16, color: Color(0xff8F9799)),
          _buildTile(items2, switch2, onSwitch2Changed),
          Divider(indent: 16, endIndent: 16, color: Color(0xff8F9799)),
          _buildTile(items3, switch3, onSwitch3Changed),
        ],
      ),
    );
  }
}
