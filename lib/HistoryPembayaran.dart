import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Historypembayaran extends StatelessWidget {
  const Historypembayaran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_back_ios),
                  Spacer(),
                  Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_back_ios, color: Colors.white),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Pilih paket langganan bulanan untuk layanan edukasi kami. Bisa dibatalkan kapan saja!',
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 15),
              _buildTiers(200000, '18 Sep 2025', 565745433, false),
              SizedBox(height: 10),
              _buildTiers(200000, '18 Sep 2025', 565745434, true),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTiers(int price, String date, int transactionID, bool success) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          offset: Offset(2, 4),
          spreadRadius: 1,
          blurRadius: 4,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Wallet
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(0xffB9D2E3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.wallet, color: Color(0xff1C6EA4)),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Tier 3'), Text('Rp $price'), Text(date)],
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [Text('ID Transaksi'), Text('$transactionID')]),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: success ? Color(0xff58A700) : Color(0xffFF4B4B),
                  ),
                  color: success ? Color(0xffD7FFB8) : Color(0xffFF9696),
                ),
                child: Text(
                  (success ? 'Sukses' : 'Gagal'),
                  style: TextStyle(
                    color: success ? Color(0xff58A700) : Color(0xffFF4B4B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
