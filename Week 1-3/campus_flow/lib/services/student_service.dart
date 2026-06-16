import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentService {
  static const String _storageKey = 'students_list';

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> _saveStudents(List<Map<String, dynamic>> students) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(students));
  }

  static Future<void> addStudent(Map<String, dynamic> student) async {
    final students = await getStudents();
    students.add(student);
    await _saveStudents(students);
  }

  static Future<void> deleteStudent(String id) async {
    final students = await getStudents();
    students.removeWhere((student) => student['id'] == id);
    await _saveStudents(students);
  }
}