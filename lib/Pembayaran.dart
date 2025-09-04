import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/PembayaranBerhasil.dart';

class Pembayaran extends StatefulWidget {
  const Pembayaran({super.key});

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  TextEditingController voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_back_ios),
                  Spacer(),
                  Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_back_ios, color: Colors.white),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 4),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      // Logo
                      SvgPicture.asset(
                        'assets/transparentlogoclored.svg',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Untuk individu dan pembelajar serius',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff969696),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Rp.50,000'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Voucher',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              TextField(
                controller: voucherController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ), // Reduced vertical padding
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      'assets/cek.svg',
                      width: 15,
                      height: 15,
                    ),
                  ),
                  hintText: 'Masukkan Kode Anda',
                ),
              ),
              SizedBox(height: 20),
              Bill("Subtotal", "50.000"),
              Bill("Biaya Admin", "2.500"),
              SubstractBill("Kode Voucher", "10.000"),
              Spacer(),
              Bill("Total", "42.500"),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                  backgroundColor: Color(0xff1C6EA4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PembayaranSuccess(),
                    ),
                  );
                },
                child: Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

Widget Bill(String name, String price) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      Text(
        'Rp.$price',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

Widget SubstractBill(String name, String price) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Kode voucher',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      Text('-Rp.$price', style: TextStyle(fontSize: 15, color: Colors.red)),
    ],
  );
}
