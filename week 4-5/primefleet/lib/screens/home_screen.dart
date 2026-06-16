import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fleet_screen.dart';
import 'tyre_screen.dart';
import 'maintenance_screen.dart';
import 'profile_screen.dart';
import '../api_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    FleetScreen(),
    TyreScreen(),
    MaintenanceScreen(),
    ProfileScreen(),
    ApiScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Optional: listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Double-check authentication before building
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF0D47A1),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Fleet'),
              BottomNavigationBarItem(icon: Icon(Icons.tire_repair), label: 'Tyres'),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Maintenance'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.cloud_queue), label: 'API'),
            ],
          ),
        ),
      ),
    );
  }
}