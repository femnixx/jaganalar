import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/Pembayaran.dart';

class Premium2 extends StatefulWidget {
  const Premium2({super.key});

  @override
  State<Premium2> createState() => _Premium2State();
}

class _Premium2State extends State<Premium2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                      'Langgananku2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
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
                  'Pilih paket langganan bulanan untuk layanan edukasi kami. Bisa dibatalkan kapan saja!',
                  style: TextStyle(fontSize: 14, color: Color(0xff717171)),
                  textAlign: TextAlign.center, // Center align for better look
                ),
                SizedBox(height: 20),
                SvgPicture.asset(
                  'assets/transparentlogoclored.svg',
                  width: 180,
                  height: 140,
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Pilih Paket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffB9D2E3), Color(0xff97BCD5)],
                    ),
                    border: Border.all(color: Color(0xff1C6EA4), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff1C6EA4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Populer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Rp.50.000/bulan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('Untuk individu dan pembelajar serius'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildFeatureBox(),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xff1C6EA4),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // do whatever
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Pembayaran()),
                    );
                  },
                  child: Text(
                    'Lanjutkan - Rp.50.000 Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Dengan melanjutkan pesanan ini, Anda menyetujui Syarat & Ketentuan, Langganan akan diperpanjang otomatis kecuali dinonaktifkan minimal 24 jam sebelum period berakhir.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBox() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xff1C6EA4), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                title: 'Quiz',
                description: 'Akses penuh ke Halaman Kuis',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                title: 'Quiz',
                description: 'Bisa main ulang kuis kapan saja',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                title: 'Quiz',
                description:
                    'Mendapatkan XP tambahan (1/3 dari percobaan pertama) setiap kali main ulang',
              ),
            ],
          ),
        ),

        Positioned(
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xff1C6EA4), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Termasuk',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, color: Colors.black, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
