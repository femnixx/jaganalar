import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(Color(0xff1C6EA4)),
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
          ],
        ),
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

              /// DOTS
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
                  minimumSize: WidgetStateProperty.all(
                    Size(double.infinity, 52),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Color(0xff1C6EA4)),
                ),
                onPressed: () {
                  if (_controller.page == _pageCount - 1) {
                    // last page → navigate
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Signin()),
                    );
                    print("Go to Home");
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
    );
  }

  Widget buildPage({
    required String firstText,
    required String secondText,
    required bool isFirstBlue,
    required String subtitle,
    bool isStacked = false, // new flag
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

class OnboardingPage extends StatelessWidget {
  final String title1;
  final Color title1Color;
  final String title2;
  final String description;
  final VoidCallback onNext;

  const OnboardingPage({
    super.key,
    required this.title1,
    required this.title1Color,
    required this.title2,
    required this.description,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title1,
                  style: TextStyle(
                    color: title1Color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title2,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            // Next button
            ElevatedButton(onPressed: onNext, child: const Text('Lanjutkan')),

            const SizedBox(height: 40), // spacing from bottom
          ],
        ),
      ),
    );
  }
}
