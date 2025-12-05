import 'package:flutter/material.dart';
import 'package:neobazaar/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _textAnimationController;
  Widget _buildImage(String src) {
    if (src.startsWith('http')) {
      return Image.network(src, height: 300);
    }
     return Image.asset(src, height: 300);
  }

  final List<Map<String, String>> pages = [
    {
      "title": "Welcome to NeoBazaar",
      "desc": "Nepal's first AI-powered marketplace",
      "image": "images/NeoBazaar_Logo.png"
    },
    {
      "title": "AI Product Check",
      "desc": "Verifies condition & price instantly",
      "image": "images/ProductCheck.png"
    },
    {
      "title": "Earn NeoTokens",
      "desc": "List items → Get rewards → Top the leaderboard",
      "image": "images/EarnNeoTokens.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textAnimationController.forward();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _textAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                  _textAnimationController.reset();
                  _textAnimationController.forward();
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        child: _buildImage(pages[index]["image"]!)),
                      const SizedBox(height: 50),
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                          CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
                        ),
                        child: FadeTransition(
                          opacity: _textAnimationController,
                          child: Text(
                            pages[index]["title"]!,
                            style: const TextStyle(color: Color(0xFFFF9933), fontSize: 28, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                          CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
                        ),
                        child: FadeTransition(
                          opacity: _textAnimationController,
                          child: Text(
                            pages[index]["desc"]!,
                            style: const TextStyle(color: Colors.white70, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text("Skip", style: TextStyle(color: Color(0xFFFF9933), fontSize: 18)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9933)),
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
      ),
    );
  }
}