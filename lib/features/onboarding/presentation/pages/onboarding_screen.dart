import 'package:flutter/material.dart';
import 'package:neobazaar/app/theme/app_colors.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _textAnimationController;
  Widget _buildImage(String src) {
    if (src.startsWith('http')) {
      return Image.network(src, fit: BoxFit.contain);
    }
    return Image.asset(src, fit: BoxFit.contain);
  }

  final List<Map<String, String>> pages = [
    {
      "title": "Welcome to NeoBazaar",
      "desc": "Nepal's first AI-powered marketplace",
      "image": "assets/images/onboarding/NeoBazaar_Logo.png",
    },
    {
      "title": "AI Product Check",
      "desc": "Verifies condition & price instantly",
      "image": "assets/images/onboarding/ProductCheck.png",
    },
    {
      "title": "Earn NeoTokens",
      "desc": "List items -> Get rewards -> Top the leaderboard",
      "image": "assets/images/onboarding/EarnNeoTokens.png",
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Stack(
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
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 50,
                  top: 20,
                  bottom: 140,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      child: _buildImage(pages[index]["image"]!),
                    ),
                    const SizedBox(height: 50),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _textAnimationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _textAnimationController,
                        child: Text(
                          pages[index]["title"]!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _textAnimationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _textAnimationController,
                        child: Text(
                          pages[index]["desc"]!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
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
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
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
                GradientButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  text: "Skip",

                  // style: TextStyle(color: Color(0xFF6B46C1), fontSize: 18),
                ),
                GradientButton(
                  onPressed: () {
                    if (_currentPage == pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const LoginScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                        ),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  text: _currentPage == pages.length - 1
                      ? "Get Started"
                      : "Next",
                  gradient: AppColors.primaryGradient,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
