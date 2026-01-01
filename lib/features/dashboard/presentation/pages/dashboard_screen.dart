import 'package:flutter/material.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/browse_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/home_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/message_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/post_screen.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/profile_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    BrowseScreen(),
    PostScreen(),
    MessageScreen(),
    ProfileScreens(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
