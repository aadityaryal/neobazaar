import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Welcome to NeoBazaar",
      "desc": "Nepal's first AI-powered marketplace",
      "image": "https://via.placeholder.com/300/FF9933/FFFFFF?text=1"
    },
    {
      "title": "AI Product Check",
      "desc": "YOLOv8 verifies condition & price instantly",
      "image": "https://via.placeholder.com/300/0055A4/FFFFFF?text=2"
    },
    {
      "title": "Earn NeoTokens",
      "desc": "List items → Get rewards → Top the leaderboard",
      "image": "https://via.placeholder.com/300/0F172A/FFFFFF?text=3"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(pages[index]["image"]!, height: 300),
                    const SizedBox(height: 50),
                    Text(
                      pages[index]["title"]!,
                      style: const TextStyle(color: Color(0xFFFF9933), fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      pages[index]["desc"]!,
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Dots Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFFFF9933) : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Buttons
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Skip → Login (later)
                  },
                  child: const Text("Skip", style: TextStyle(color: Color(0xFFFF9933), fontSize: 18)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9933)),
                  onPressed: () {
                    if (_currentPage == pages.length - 1) {
                      // Go to Login (later)
                    } else {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    }
                  },
                  child: Text(_currentPage == pages.length - 1 ? "Get Started" : "Next", style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}