import 'package:flutter/material.dart';
import '../services/student_service.dart';

class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await StudentService.getStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteStudent(String id) async {
    await StudentService.deleteStudent(id);
    _loadStudents();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Student deleted"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Records", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4657C8), Color(0xFF6A80F5)]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text("No students registered yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Dismissible(
            key: Key(student['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteStudent(student['id']),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4657C8),
                  child: Text(student['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text("${student['regNumber']}  •  ${student['course']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteStudent(student['id']),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}