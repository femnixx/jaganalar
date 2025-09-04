import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/EditProfile.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/Supabase.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool receiveNotifications = true;
  bool weeklyMissions = false;
  bool dailyReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
              // Akun Section
              const Text(
                'Akun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SettingsBuilder(
                items: [
                  SettingsItem(title: 'Preferensi'),
                  SettingsItem(title: 'Edit Profil', page: Editprofile()),
                  SettingsItem(title: 'Ganti Password'),
                ],
              ),
              const SizedBox(height: 20),

              // Notifikasi Section
              const Text(
                'Notifikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SettingsBuilder(
                items: [
                  SettingsItem(
                    title: 'Terima Notifikasi',
                    switchValue: receiveNotifications,
                    onSwitchChanged: (val) =>
                        setState(() => receiveNotifications = val),
                  ),
                  SettingsItem(
                    title: 'Misi Mingguan Terbaru',
                    switchValue: weeklyMissions,
                    onSwitchChanged: (val) =>
                        setState(() => weeklyMissions = val),
                  ),
                  SettingsItem(
                    title: 'Pengingat Misi Harian',
                    switchValue: dailyReminders,
                    onSwitchChanged: (val) =>
                        setState(() => dailyReminders = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Langganan Section
              const Text(
                'Langganan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
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
                        backgroundColor: const Color(0xff1C6EA4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(120, 50),
                      ),
                      onPressed: () {},
                      child: const Text(
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
              const SizedBox(height: 20),

              // Lainnya Section
              const Text(
                'Lainnya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SettingsBuilder(
                items: [
                  SettingsItem(title: 'Pusat Bantuan'),
                  SettingsItem(title: 'Kebijakan Privasi'),
                  SettingsItem(title: 'Ketentuan'),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Out Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await SupabaseService.client.auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Signin()),
                    );
                  },
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for settings items
class SettingsItem {
  final String title;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget? page;

  SettingsItem({
    required this.title,
    this.switchValue,
    this.onSwitchChanged,
    this.page,
  });
}

class SettingsBuilder extends StatelessWidget {
  const SettingsBuilder({super.key, required this.items});

  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff8F9799)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // To prevent scrolling inside the list
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.title),
            trailing: item.switchValue != null
                ? Switch(
                    value: item.switchValue!,
                    onChanged: item.onSwitchChanged,
                  )
                : const Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (item.page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.page!),
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) =>
            const Divider(indent: 16, endIndent: 16, color: Color(0xff8F9799)),
      ),
    );
  }
}
