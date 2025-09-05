import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'Supabase.dart';
import 'SignIn.dart';
import 'UserModel.dart';

// Your UserModel class should be in a separate file named 'UserModel.dart'
// and should look like this (with the phone number as a String).
// You do not need to rewrite this code in your main file.
class UserModel {
  final String? username, email, avatarUrl, phone;
  final int? missions, medals, streak, level, xp;

  UserModel({
    this.username,
    this.email,
    this.phone, // Phone number as String
    this.avatarUrl,
    this.missions,
    this.medals,
    this.streak,
    this.level,
    this.xp,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?, // Cast as a String
      avatarUrl: map['avatar_url'] as String?,
      missions: map['missions'] as int?,
      medals: map['medals'] as int?,
      streak: map['streak'] as int?,
      level: map['level'] as int?,
      xp: map['xp'] as int?,
    );
  }
}

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  UserModel? user;

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabaseClient = SupabaseService.client;
    final userId = supabaseClient.auth.currentUser?.id;

    if (userId != null) {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('uuid', userId)
          .single();

      if (response != null) {
        setState(() {
          user = UserModel.fromMap(response);
          usernameController.text = user?.username ?? '';
          phoneController.text = user?.phone ?? '';
          emailController.text = user?.email ?? '';
        });
      }
    }
  }

  Future<void> uploadProfilePicture() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final fileExt = p.extension(imageFile.path);
    final filePath = '$userId$fileExt';

    await SupabaseService.client.storage
        .from('avatars')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final imageUrl = SupabaseService.client.storage
        .from('avatars')
        .getPublicUrl(filePath);

    await SupabaseService.client
        .from('users')
        .update({'avatar_url': imageUrl})
        .eq('uuid', userId);

    setState(() {
      user = UserModel(
        username: user?.username,
        email: user?.email,
        phone: user?.phone,
        avatarUrl: imageUrl,
        missions: user?.missions,
        medals: user?.medals,
        streak: user?.streak,
        level: user?.level,
        xp: user?.xp,
      );
    });
  }

  Future<void> saveProfileChanges() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    final updates = {
      'username': usernameController.text,
      'phone': phoneController.text,
      'email': emailController.text,
    };

    try {
      await SupabaseService.client
          .from('users')
          .update(updates)
          .eq('uuid', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan!')),
      );

      setState(() {
        user = UserModel(
          username: usernameController.text,
          email: emailController.text,
          phone: phoneController.text,
          avatarUrl: user?.avatarUrl,
          missions: user?.missions,
          medals: user?.medals,
          streak: user?.streak,
          level: user?.level,
          xp: user?.xp,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyMainScreen()),
        );
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan perubahan')),
      );
    }
  }

  void logout() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        await SupabaseService.client.auth.signOut();
        if (kDebugMode) {
          print("Signed out successfully!");
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Signin()),
          );
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
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
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        const Text(
                          'Profil',
                          textAlign: TextAlign.center,
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
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 52.5,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  uploadProfilePicture();
                },
                child: const Text(
                  'GANTI FOTO PROFIL',
                  style: TextStyle(
                    color: Color(0xff1C6EA4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama lengkap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'raion',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nomor Telepon',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '08232328931',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'raion@gmail.com',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (usernameController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty &&
                                emailController.text.isNotEmpty)
                            ? const Color(0xff1C6EA4) // Active color
                            : const Color(0xffD7D7D7), // Inactive color
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (usernameController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty &&
                            emailController.text.isNotEmpty) {
                          await saveProfileChanges();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All fields must be filled'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color:
                              (usernameController.text.isNotEmpty &&
                                  phoneController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty)
                              ? Colors
                                    .white // Active text color
                              : const Color(0xff717171),
                        ), // Inactive text color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
