// Cover section
Container(
  width: double.infinity,
  height: screenHeight * 0.4,
  child: Stack(
    fit: StackFit.expand,
    children: [
      SvgPicture.asset(
        'assets/Container.svg',
        fit: BoxFit.cover,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/checksilver.svg', height: 120),
          const SizedBox(height: 16),
          const Text(
            'Misi Mingguan selesai!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu berhasil menuntaskan tantangan pekan ini.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ],
  ),
),
