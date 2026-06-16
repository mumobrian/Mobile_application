import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF0D47A1),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            SizedBox(height: 10),

            Text("Fleet Manager",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            Text("manager@primefleet.com"),

          ],
        ),
      ),
    );
  }
}