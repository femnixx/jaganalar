import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Pengaturan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(children: [Icon(Icons.arrow_back_ios)]),
                ],
              ),
              SizedBox(height: 5),
              Divider(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text('Akun', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              SettingsBuilder(
                items1: 'Preferensi',
                items2: 'Edit Profil',
                items3: 'Ganti Password',
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
  });
  final String items1, items2, items3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: BoxBorder.all(color: Color(0xff8F9799)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('$items1'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to a profile page
            },
          ),
          SizedBox(
            width: double.infinity,
            child: Divider(indent: 16, endIndent: 16, color: Color(0xff8F9799)),
          ),
          ListTile(
            title: Text('$items2'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to a notifications settings page
            },
          ),
          Divider(indent: 16, endIndent: 16, color: Color(0xff8F9799)),
          ListTile(
            title: Text('$items3'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to a security settings page
            },
          ),
        ],
      ),
    );
  }
}
