import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Premium2.dart';

class Premium extends StatefulWidget {
  const Premium({super.key});

  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios),
                  Text(
                    'Langgananku',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xffB9D2E3),
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Set the border radius
                    ),
                    child: Icon(
                      color: Color(0xff1C6EA4),
                      Icons.restart_alt,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Pilih paket langganan bulana untnnuk layanan edukasi kami. Bisa dibatalkan kapan saja!',
                style: TextStyle(fontSize: 14, color: Color(0xff717171)),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              SvgPicture.asset(
                'assets/transparentlogo.svg',
                width: 180,
                height: 140,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff1C6EA4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gratis',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff1C6EA4),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Untuk individu yanng ingin mencoba aplikasi secara personal',
                        style: TextStyle(color: Color(0xff969696)),
                      ),
                      Divider(),
                      Text('• Akses misi harian (kuis & trivia singkat)'),
                      SizedBox(height: 5),
                      Text('• Ikut misi mingguan ndengan batasan tertentu'),
                      SizedBox(height: 5),
                      Text('• Ikut ruang diskusi komunitas'),
                      // The button has been removed from here.
                    ],
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                  backgroundColor: Color(0xff1C6EA4),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  // do whatever
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Premium2()),
                  );
                },
                child: Text(
                  'Dapatkan JagaNalar Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
