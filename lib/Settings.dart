import 'package:flutter/material.dart';
import 'package:jaganalar/EditProfile.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:jaganalar/Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool receiveNotifications = true;
  bool weeklyMissions = false;
  bool dailyReminders = true;

  // -----------------------------
  // Sign-out method
  // -----------------------------
  Future<void> _signOut() async {
    try {
      // 1️⃣ Sign out from Supabase
      await SupabaseService.client.auth.signOut();

      // 2️⃣ Navigate to SignIn screen and remove all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Signin()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal sign out, coba lagi")),
      );
    }
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Akun Section
              const SectionTitle(title: 'Akun'),
              const SizedBox(height: 6),
              SettingsBuilder(
                items: [
                  const SettingsItem(title: 'Preferensi'),
                  const SettingsItem(title: 'Edit Profil', page: Editprofile()),
                  const SettingsItem(title: 'Ganti Password'),
                ],
              ),
              const SizedBox(height: 20),

              // Notifikasi Section
              const SectionTitle(title: 'Notifikasi'),
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
              const SectionTitle(title: 'Langganan'),
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
              const SectionTitle(title: 'Lainnya'),
              const SizedBox(height: 6),
              SettingsBuilder(
                items: const [
                  SettingsItem(title: 'Pusat Bantuan'),
                  SettingsItem(title: 'Kebijakan Privasi'),
                  SettingsItem(title: 'Ketentuan'),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Out Button
              Center(
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// Reusable Components
// -----------------------------
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class SettingsItem {
  final String title;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget? page;

  const SettingsItem({
    required this.title,
    this.switchValue,
    this.onSwitchChanged,
    this.page,
  });
}

class SettingsBuilder extends StatelessWidget {
  final List<SettingsItem> items;
  const SettingsBuilder({Key? key, required this.items}) : super(key: key);

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
        physics: const NeverScrollableScrollPhysics(),
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
                  MaterialPageRoute(builder: (_) => item.page!),
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
