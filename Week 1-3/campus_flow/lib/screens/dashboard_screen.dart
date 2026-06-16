import 'package:flutter/material.dart';
import 'student_registration_screen.dart';
import 'student_records_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {"title": "Register Student", "icon": Icons.person_add, "color": Colors.blueAccent},
      {"title": "Student Records", "icon": Icons.people, "color": Colors.deepPurpleAccent},
      {"title": "Settings", "icon": Icons.settings, "color": Colors.orangeAccent},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("CampusFlow Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4657C8), Color(0xFF6A80F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRegistrationScreen()));
                } else if (index == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRecordsScreen()));
                } else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cards[index]["color"] as Color, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cards[index]["icon"] as IconData, size: 58, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      cards[index]["title"] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}