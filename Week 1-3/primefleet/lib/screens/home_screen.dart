import 'package:flutter/material.dart';
import 'fleet_screen.dart';
import 'tyre_screen.dart';
import 'maintenance_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FleetScreen(),
    TyreScreen(),
    MaintenanceScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  // Dynamic FAB icon and action based on selected tab
  Widget _buildFloatingActionButton() {
    IconData icon;
    VoidCallback onPressed;

    switch (_currentIndex) {
      case 0: // Fleet
        icon = Icons.directions_car;
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new vehicle - Coming soon')),
          );
        };
        break;
      case 1: // Tyre
        icon = Icons.tire_repair;
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new tyre - Coming soon')),
          );
        };
        break;
      case 2: // Maintenance
        icon = Icons.build;
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule maintenance - Coming soon')),
          );
        };
        break;
      default: // Profile
        icon = Icons.person;
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit profile - Coming soon')),
          );
        };
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 4,
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFE9EDF2)],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
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
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
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
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Fleet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tire_repair),
                label: 'Tyres',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: 'Maintenance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}