import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaganalar/SignIn.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final int _pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background SVG that covers the whole screen
        Positioned.fill(
          child: SvgPicture.asset('assets/copypaste2.svg', fit: BoxFit.cover),
        ),

        // Scaffold for content, AppBar, buttons, etc.
        Scaffold(
          backgroundColor: Colors.transparent, // important!
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Color(0xff1C6EA4)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                },
                child: Text(
                  'Lewati',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      children: [
                        buildPage(
                          firstText: "Asah Nalar ",
                          secondText: "Setiap Hari",
                          isFirstBlue: true,
                          subtitle:
                              "Dapatkan tantangan singkat berupa kuis dan trivia untuk melatih literasi digitalmu.",
                        ),
                        buildPage(
                          firstText: "Jejak Belajarmu ",
                          secondText: "Tersimpan",
                          isStacked: true,
                          isFirstBlue: false,
                          subtitle:
                              "Lihat kembali misi yang sudah kamu selesaikan dan pantau perkembanganmu",
                        ),
                        buildPage(
                          firstText: "Belajar Jadi ",
                          secondText: "Seru",
                          isFirstBlue: false,
                          subtitle:
                              "Kumpulkan XP, naik level, dan raih badge keren di leaderboard",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pageCount,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                        Size(double.infinity, 52),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xff1C6EA4),
                      ),
                    ),
                    onPressed: () {
                      if (_controller.page == _pageCount - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Signin()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      "Lanjutkan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPage({
    required String firstText,
    required String secondText,
    required bool isFirstBlue,
    required String subtitle,
    bool isStacked = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          isStacked
              ? Column(
                  children: [
                    Text(
                      firstText,
                      style: TextStyle(
                        color: isFirstBlue
                            ? const Color(0xff1C6EA4)
                            : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      secondText,
                      style: TextStyle(
                        color: !isFirstBlue
                            ? const Color(0xff1C6EA4)
                            : Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      firstText,
                      style: TextStyle(
                        color: isFirstBlue
                            ? const Color(0xff1C6EA4)
                            : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      secondText,
                      style: TextStyle(
                        color: !isFirstBlue
                            ? const Color(0xff1C6EA4)
                            : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
