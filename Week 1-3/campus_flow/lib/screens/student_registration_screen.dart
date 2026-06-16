import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/student_service.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final nameController = TextEditingController();
  final regController = TextEditingController();
  final courseController = TextEditingController();

  Future<void> _registerStudent() async {
    final name = nameController.text.trim();
    final reg = regController.text.trim();
    final course = courseController.text.trim();

    if (name.isEmpty || reg.isEmpty || course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required"), backgroundColor: Colors.red),
      );
      return;
    }

    final newStudent = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name,
      "regNumber": reg,
      "course": course,
    };

    await StudentService.addStudent(newStudent);

    nameController.clear();
    regController.clear();
    courseController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Student registered locally!"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Student", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4657C8), Color(0xFF6A80F5)]),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(nameController, "Student Name", Icons.person),
            const SizedBox(height: 18),
            _buildTextField(regController, "Registration Number", Icons.numbers),
            const SizedBox(height: 18),
            _buildTextField(courseController, "Course", Icons.book),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4657C8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: const Text("SAVE STUDENT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4657C8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF4657C8), width: 2),
        ),
      ),
    );
  }
}