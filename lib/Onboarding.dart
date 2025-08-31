import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo, change when logo is done or whatever
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xff1C6EA4)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Text(
                      'Logo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ) 
      ),
    );
  }
}